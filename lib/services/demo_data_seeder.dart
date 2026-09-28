import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ============================================================
// DEMO DATA SEEDER
//
// Adds the 8 demo fandoms to Firestore in one tap.
//  - Uses FIXED document ids ("demo_naruto", ...) so running it twice
//    never creates duplicates.
//  - Existing docs are skipped unless overwrite = true. On overwrite
//    the image fields are NOT touched, so images you added later
//    (via Manage Fandoms > Edit) are kept.
//  - New docs start with NO image (the app shows its placeholder).
//    Add real images afterwards via Manage Fandoms > Edit.
//  - Events (and later products) reference the fandom ids through
//    DemoDataSeeder.fandomIds.
//  - Event dates are calculated from the moment you seed, so the
//    "upcoming" list is never empty and a few past events always exist.
// ============================================================

class SeedResult {
  const SeedResult({required this.added, required this.skipped});
  final int added;
  final int skipped;
}

class _FandomSeed {
  const _FandomSeed({
    required this.id,
    required this.name,
    required this.category,
    required this.tagline,
    required this.description,
    required this.beginnerGuide,
    required this.glossary,
    required this.deepDive,
    required this.resources,
    this.trending = false,
  });

  final String id;
  final String name;
  final String category;
  final String tagline;
  final String description;
  final String beginnerGuide;

  /// One "Term: meaning" per line.
  final String glossary;

  /// One fact per line.
  final String deepDive;

  /// One "type | title | url" per line.
  final String resources;
  final bool trending;
}

class _EventSeed {
  const _EventSeed({
    required this.id,
    required this.fandom,
    required this.title,
    required this.category,
    required this.location,
    required this.city,
    required this.description,
    required this.dayOffset,
    required this.startHour,
    this.durationHours = 4,
    this.durationDays = 0,
    this.ticketLink = '',
  });

  final String id;

  /// Fandom name, must be a key of DemoDataSeeder.fandomIds.
  final String fandom;
  final String title;
  final String category;
  final String location;
  final String city;
  final String description;

  /// Days from today (negative = past event).
  final int dayOffset;
  final int startHour;
  final int durationHours;

  /// Extra days for multi-day events (0 = same-day event).
  final int durationDays;
  final String ticketLink;
}

class _ProductSeed {
  const _ProductSeed(
    this.id,
    this.fandom,
    this.name,
    this.category,
    this.price,
    this.stock,
    this.description,
  );

  final String id;

  /// Fandom name, must be a key of DemoDataSeeder.fandomIds.
  final String fandom;
  final String name;
  final String category;

  /// Price in PKR.
  final int price;
  final int stock;
  final String description;
}

class DemoDataSeeder {
  DemoDataSeeder({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Fandom name -> Firestore document id. Use these in event/product seeds.
  static const Map<String, String> fandomIds = {
    'Naruto': 'demo_naruto',
    'Marvel Cinematic Universe': 'demo_mcu',
    'Star Wars': 'demo_star_wars',
    'Harry Potter': 'demo_harry_potter',
    'The Legend of Zelda': 'demo_zelda',
    'Stranger Things': 'demo_stranger_things',
    'K-Pop': 'demo_kpop',
    'Spider-Man': 'demo_spider_man',
  };

  // ------------------------------------------------------------
  // PARSERS (same formats you'd type into the Create Fandom form)
  // ------------------------------------------------------------

  static List<String> _lines(String text) => text
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  static List<Map<String, String>> _glossary(String text) {
    final result = <Map<String, String>>[];
    for (final line in _lines(text)) {
      final i = line.indexOf(':');
      if (i <= 0) continue;
      result.add({
        'term': line.substring(0, i).trim(),
        'meaning': line.substring(i + 1).trim(),
      });
    }
    return result;
  }

  static List<Map<String, String>> _resources(String text) {
    final result = <Map<String, String>>[];
    for (final line in _lines(text)) {
      final parts = line.split(' | ');
      if (parts.length < 3) continue;
      result.add({
        'type': parts[0].trim().toLowerCase(),
        'title': parts[1].trim(),
        'url': parts.sublist(2).join(' | ').trim(),
      });
    }
    return result;
  }

  // ------------------------------------------------------------
  // SEED FANDOMS
  // ------------------------------------------------------------

  Future<SeedResult> seedFandoms({bool overwrite = false}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('You must be logged in as admin.');

    final collection = _firestore.collection('fandoms');
    int added = 0;
    int skipped = 0;

    for (final seed in _fandomSeeds) {
      final ref = collection.doc(seed.id);
      final existing = await ref.get();

      if (existing.exists && !overwrite) {
        skipped++;
        continue;
      }

      final data = <String, dynamic>{
        'name': seed.name,
        'category': seed.category,
        'tagline': seed.tagline,
        'description': seed.description,
        'beginnerGuide': seed.beginnerGuide,
        'glossary': _glossary(seed.glossary),
        'deepDive': _lines(seed.deepDive),
        'resources': _resources(seed.resources),
        'isTrending': seed.trending,
        'fandomId': 'FND-${seed.id.toUpperCase()}',
        'status': 'approved',
        'isActive': true,
        'isDemo': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!existing.exists) {
        data['imageUrl'] = '';
        data['images'] = <String>[];
        data['createdBy'] = user.uid;
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await ref.set(data, SetOptions(merge: true));
      added++;
    }

    return SeedResult(added: added, skipped: skipped);
  }

  // ------------------------------------------------------------
  // SEED EVENTS
  // ------------------------------------------------------------

  Future<SeedResult> seedEvents({bool overwrite = false}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('You must be logged in as admin.');

    final collection = _firestore.collection('events');
    final now = DateTime.now();
    int added = 0;
    int skipped = 0;

    for (final seed in _eventSeeds) {
      final fandomId = fandomIds[seed.fandom];
      if (fandomId == null) {
        throw Exception('Unknown fandom "${seed.fandom}" in event ${seed.id}.');
      }

      final ref = collection.doc(seed.id);
      final existing = await ref.get();

      if (existing.exists && !overwrite) {
        skipped++;
        continue;
      }

      final start = DateTime(
        now.year,
        now.month,
        now.day + seed.dayOffset,
        seed.startHour,
      );
      final end = start.add(
        Duration(days: seed.durationDays, hours: seed.durationHours),
      );

      final data = <String, dynamic>{
        'eventId': seed.id,
        'title': seed.title,
        'description': seed.description,
        'fandomId': fandomId,
        'category': seed.category,
        'location': seed.location,
        'city': seed.city,
        'ticketLink': seed.ticketLink,
        'startAt': Timestamp.fromDate(start),
        'endAt': Timestamp.fromDate(end),
        'isPublished': true,
        'isDemo': true,
        'updatedAt': Timestamp.now(),
      };

      // Images are left alone on overwrite so ones added later survive.
      if (!existing.exists) {
        data['imageUrl'] = '';
        data['imageUrls'] = <String>[];
        data['createdBy'] = user.uid;
        data['createdAt'] = Timestamp.now();
      }

      await ref.set(data, SetOptions(merge: true));
      added++;
    }

    return SeedResult(added: added, skipped: skipped);
  }

  // ------------------------------------------------------------
  // SEED PRODUCTS
  // ------------------------------------------------------------

  Future<SeedResult> seedProducts({bool overwrite = false}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('You must be logged in as admin.');

    final collection = _firestore.collection('products');
    int added = 0;
    int skipped = 0;

    for (final seed in _productSeeds) {
      final fandomId = fandomIds[seed.fandom];
      if (fandomId == null) {
        throw Exception('Unknown fandom "${seed.fandom}" in ${seed.id}.');
      }

      final ref = collection.doc(seed.id);
      final existing = await ref.get();

      if (existing.exists && !overwrite) {
        skipped++;
        continue;
      }

      final data = <String, dynamic>{
        'name': seed.name,
        'description': seed.description,
        'price': seed.price,
        'currency': 'PKR',
        'fandomId': fandomId,
        'category': seed.category,
        'stock': seed.stock,
        'isAvailable': true,
        'isDemo': true,
        'updatedAt': Timestamp.now(),
      };

      // Images are left alone on overwrite so ones added later survive.
      if (!existing.exists) {
        data['imageUrl'] = '';
        data['imageUrls'] = <String>[];
        data['createdBy'] = user.uid;
        data['createdAt'] = Timestamp.now();
      }

      await ref.set(data, SetOptions(merge: true));
      added++;
    }

    return SeedResult(added: added, skipped: skipped);
  }

  /// Run every seeder.
  Future<String> seedAll({bool overwrite = false}) async {
    final fandoms = await seedFandoms(overwrite: overwrite);
    final events = await seedEvents(overwrite: overwrite);
    final products = await seedProducts(overwrite: overwrite);
    return 'Fandoms: ${fandoms.added} added, ${fandoms.skipped} skipped. '
        'Events: ${events.added} added, ${events.skipped} skipped. '
        'Products: ${products.added} added, ${products.skipped} skipped.';
  }
}

// ============================================================
// BUTTON — drop this anywhere in the admin panel
//   const SeedDemoDataButton()
// ============================================================

class SeedDemoDataButton extends StatefulWidget {
  const SeedDemoDataButton({super.key});

  @override
  State<SeedDemoDataButton> createState() => _SeedDemoDataButtonState();
}

class _SeedDemoDataButtonState extends State<SeedDemoDataButton> {
  bool _busy = false;

  Future<void> _run() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final message = await DemoDataSeeder().seedAll();
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Permission denied. Check your Firestore rules.'
                : 'Seeding failed: ${e.message ?? e.code}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Seeding failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _busy ? null : _run,
        icon: _busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload_outlined),
        label: Text(_busy ? 'Seeding...' : 'Seed demo data'),
      ),
    );
  }
}

// ============================================================
// FANDOM DEMO DATA
// ============================================================

const List<_FandomSeed> _fandomSeeds = [
  _FandomSeed(
    id: 'demo_naruto',
    name: 'Naruto',
    category: 'Anime',
    tagline: "A young ninja's quest to become Hokage",
    description:
        "Naruto follows Naruto Uzumaki, an outcast ninja of the Hidden Leaf Village who dreams of becoming Hokage, the village's leader. Created by Masashi Kishimoto, the story blends action, friendship, and rivalry across two anime series and a sequel, Boruto.",
    beginnerGuide:
        'Start with the original Naruto anime (or manga), continue with Naruto Shippuden, and finish with Boruto: Naruto Next Generations.',
    glossary: '''
Hokage: The leader of a ninja village
Chakra: The energy ninja use to perform jutsu
Jutsu: A ninja technique or special ability
Shinobi: Another word for ninja
Jinchuriki: A person who holds a tailed beast inside them
Sharingan: A special eye power of the Uchiha clan
''',
    deepDive: '''
The manga was created by Masashi Kishimoto and serialized in Weekly Shonen Jump from 1999 to 2014.
The manga ran for 700 chapters collected in 72 volumes.
Naruto's fox spirit is Kurama, the Nine-Tailed Fox.
''',
    resources: '''
video | Naruto official trailers | https://www.youtube.com/results?search_query=Naruto+official+trailer
news | Latest Naruto news | https://www.google.com/search?q=Naruto+news&tbm=nws
podcast | Naruto podcasts | https://open.spotify.com/search/Naruto%20podcast
''',
  ),
  _FandomSeed(
    id: 'demo_mcu',
    name: 'Marvel Cinematic Universe',
    category: 'Movies',
    tagline: 'A shared universe of heroes',
    description:
        'The MCU is a series of interconnected superhero films and shows produced by Marvel Studios, based on Marvel Comics characters. It began with Iron Man in 2008 and grew into one of the biggest film franchises in the world.',
    beginnerGuide:
        'Watch in release order starting with Iron Man (2008). The first three phases are known as the Infinity Saga and lead up to Avengers: Endgame.',
    glossary: '''
Avengers: Earth's mightiest heroes team
Infinity Stones: Six powerful gems that control aspects of reality
Multiverse: Many parallel universes that exist side by side
Variant: An alternate version of a character from another timeline
Post-credits scene: A bonus scene after the credits that hints at what comes next
Easter egg: A hidden reference to the comics or other stories
''',
    deepDive: '''
Iron Man (2008) was the first film in the MCU.
Stan Lee, co-creator of many Marvel heroes, made cameo appearances in many MCU films.
Avengers: Endgame (2019) concluded the Infinity Saga.
''',
    resources: '''
video | Marvel Studios trailers | https://www.youtube.com/results?search_query=Marvel+Studios+official+trailer
news | Latest MCU news | https://www.google.com/search?q=Marvel+Cinematic+Universe+news&tbm=nws
podcast | MCU podcasts | https://open.spotify.com/search/Marvel%20Cinematic%20Universe%20podcast
''',
    trending: true,
  ),
  _FandomSeed(
    id: 'demo_star_wars',
    name: 'Star Wars',
    category: 'Movies',
    tagline: 'A galaxy far, far away',
    description:
        'Star Wars is a space-fantasy saga created by George Lucas, following the struggle between the Jedi and the Sith, and the rebels against the Empire. It spans films, TV series, books, comics, and games.',
    beginnerGuide:
        'Start with Episode IV: A New Hope (1977) and continue with Episodes V and VI. Then explore the prequels and the newer series.',
    glossary: '''
The Force: A mystical energy field that some beings can use
Jedi: Peacekeepers who follow the light side of the Force
Sith: Dark side users and the enemies of the Jedi
Lightsaber: A sword made of energy, used by Jedi and Sith
Padawan: A Jedi apprentice
Droid: A robot, such as R2-D2 or C-3PO
''',
    deepDive: '''
The first film, later titled A New Hope, was released in 1977.
Disney acquired Lucasfilm, the company behind Star Wars, in 2012.
Fans celebrate Star Wars Day every year on May 4.
''',
    resources: '''
video | Star Wars trailers | https://www.youtube.com/results?search_query=Star+Wars+official+trailer
news | Latest Star Wars news | https://www.google.com/search?q=Star+Wars+news&tbm=nws
podcast | Star Wars podcasts | https://open.spotify.com/search/Star%20Wars%20podcast
''',
  ),
  _FandomSeed(
    id: 'demo_harry_potter',
    name: 'Harry Potter',
    category: 'Books',
    tagline: 'The boy who lived',
    description:
        'Harry Potter is a fantasy series by J. K. Rowling about a young wizard who attends Hogwarts School of Witchcraft and Wizardry and faces the dark wizard Lord Voldemort. The seven main books were adapted into eight films.',
    beginnerGuide:
        "Read the seven books in order, starting with Harry Potter and the Philosopher's Stone, then watch the films.",
    glossary: '''
Muggle: A person born without magical ability
Quidditch: A wizard sport played on flying broomsticks
Horcrux: An object holding a fragment of a dark wizard's soul
Patronus: A protective spell that takes the form of a guardian animal
Hogwarts Houses: Gryffindor, Hufflepuff, Ravenclaw and Slytherin
Auror: A wizard who catches dark wizards
''',
    deepDive: '''
The first book was published in 1997.
The seven main books were adapted into eight films.
Students at Hogwarts are sorted into one of four houses by the Sorting Hat.
''',
    resources: '''
video | Harry Potter film trailers | https://www.youtube.com/results?search_query=Harry+Potter+official+trailer
news | Latest Harry Potter news | https://www.google.com/search?q=Harry+Potter+news&tbm=nws
podcast | Harry Potter podcasts | https://open.spotify.com/search/Harry%20Potter%20podcast
''',
  ),
  _FandomSeed(
    id: 'demo_zelda',
    name: 'The Legend of Zelda',
    category: 'Games',
    tagline: 'Adventure across Hyrule',
    description:
        'The Legend of Zelda is an action-adventure game series from Nintendo in which the hero Link explores the kingdom of Hyrule to save Princess Zelda and defeat the villain Ganon. It is known for exploration, puzzles, and memorable music.',
    beginnerGuide:
        'Each game tells its own story, so you can start almost anywhere. Breath of the Wild is a popular modern starting point.',
    glossary: '''
Hyrule: The kingdom where most Zelda games take place
Triforce: Three golden triangles of Power, Wisdom and Courage
Master Sword: The legendary blade that repels evil
Rupee: The in-game currency
Link: The hero of the series (not Zelda!)
Ganon: The main villain of the series
''',
    deepDive: '''
The first Legend of Zelda game was released in 1986.
The series was created by Shigeru Miyamoto and Takashi Tezuka.
Breath of the Wild launched in 2017 alongside the Nintendo Switch.
''',
    resources: '''
video | Zelda game trailers | https://www.youtube.com/results?search_query=Legend+of+Zelda+official+trailer
news | Latest Zelda news | https://www.google.com/search?q=Legend+of+Zelda+news&tbm=nws
podcast | Zelda podcasts | https://open.spotify.com/search/Legend%20of%20Zelda%20podcast
''',
    trending: true,
  ),
  _FandomSeed(
    id: 'demo_stranger_things',
    name: 'Stranger Things',
    category: 'TV Shows',
    tagline: 'Adventure in the Upside Down',
    description:
        'Stranger Things is a science-fiction horror series created by the Duffer Brothers, set in the 1980s in the small town of Hawkins, Indiana. A group of kids and a girl with psychic powers face secret experiments and a dark parallel world.',
    beginnerGuide:
        'Watch from Season 1 in order, since each season builds directly on the one before.',
    glossary: '''
Upside Down: A dark parallel version of Hawkins
Demogorgon: The monster from the first season
Hawkins: The small Indiana town where the story is set
Eleven: A girl with psychic abilities
Hellfire Club: The Dungeons and Dragons club at Hawkins High
Mind Flayer: A powerful shadow creature from the Upside Down
''',
    deepDive: '''
The show premiered on Netflix in July 2016.
It was created by the Duffer Brothers.
The series is packed with 1980s pop culture references and Dungeons and Dragons themes.
''',
    resources: '''
video | Stranger Things trailers | https://www.youtube.com/results?search_query=Stranger+Things+official+trailer
news | Latest Stranger Things news | https://www.google.com/search?q=Stranger+Things+news&tbm=nws
podcast | Stranger Things podcasts | https://open.spotify.com/search/Stranger%20Things%20podcast
''',
  ),
  _FandomSeed(
    id: 'demo_kpop',
    name: 'K-Pop',
    category: 'Music',
    tagline: 'Korean pop music, worldwide',
    description:
        'K-Pop is Korean popular music known for polished choreography, striking visuals, and strong fan communities. Groups and solo idols train for years before debuting and release music in cycles called comebacks.',
    beginnerGuide:
        "Pick a group or song you like, watch its official music video, then explore the members' profiles and the group's fandom name.",
    glossary: '''
Idol: A K-Pop singer or performer, often part of a group
Trainee: An aspiring idol training with an agency
Debut: An idol or group's first official release
Comeback: A new release after a break
Bias: A fan's favorite member of a group
Lightstick: A light-up item fans wave at concerts
Fandom name: The official name of a group's fans, such as ARMY for BTS
''',
    deepDive: '''
PSY's Gangnam Style (2012) was the first YouTube video to pass one billion views.
Agencies often train future idols for years before their debut.
Most groups have an official fandom name, and BTS fans are called ARMY.
''',
    resources: '''
video | K-Pop music videos | https://www.youtube.com/results?search_query=K-pop+official+music+video
news | Latest K-Pop news | https://www.google.com/search?q=K-pop+news&tbm=nws
podcast | K-Pop podcasts | https://open.spotify.com/search/K-pop%20podcast
''',
    trending: true,
  ),
  _FandomSeed(
    id: 'demo_spider_man',
    name: 'Spider-Man',
    category: 'Comics',
    tagline: 'Your friendly neighborhood hero',
    description:
        'Spider-Man is a Marvel Comics superhero created by Stan Lee and Steve Ditko, first appearing in 1962. Teenager Peter Parker gains spider-like powers and balances life as a hero with everyday problems.',
    beginnerGuide:
        'Start with a Spider-Man film you enjoy, then try classic early comics or the Spider-Verse stories.',
    glossary: '''
Spider-Sense: Peter's warning sense that alerts him to danger
Symbiote: An alien organism that bonds with a host
Venom: A villain and anti-hero formed when a symbiote bonds with Eddie Brock
Daily Bugle: The newspaper where Peter works as a photographer
Web-shooters: Peter's gadgets that shoot webbing
Spider-Verse: The multiverse of Spider-heroes
''',
    deepDive: '''
Spider-Man first appeared in Amazing Fantasy #15 in 1962.
Venom made his first full appearance in The Amazing Spider-Man #300 in 1988.
Peter Parker works as a freelance photographer for the Daily Bugle.
''',
    resources: '''
video | Spider-Man trailers | https://www.youtube.com/results?search_query=Spider-Man+official+trailer
news | Latest Spider-Man news | https://www.google.com/search?q=Spider-Man+news&tbm=nws
podcast | Spider-Man podcasts | https://open.spotify.com/search/Spider-Man%20podcast
''',
  ),
];

// ============================================================
// EVENT DEMO DATA
// Fictional fan events (no real ticket sales), spread over several
// cities, categories and dates. Negative dayOffset = past event.
// ============================================================

const List<_EventSeed> _eventSeeds = [
  // ---------------- Upcoming ----------------
  _EventSeed(
    id: 'demo_event_book_club',
    fandom: 'Harry Potter',
    title: 'Wizarding Book Club Evening',
    category: 'Meetup',
    location: 'Reader\'s Corner Cafe, Karachi',
    city: 'Karachi',
    description:
        'Sit down with fellow readers to discuss Harry Potter and the Philosopher\'s Stone over hot chocolate. Bring your favourite copy and your favourite quote.',
    dayOffset: 3,
    startHour: 17,
    durationHours: 3,
  ),
  _EventSeed(
    id: 'demo_event_kpop_listening',
    fandom: 'K-Pop',
    title: 'K-Pop Comeback Listening Party',
    category: 'Online Meetup',
    location: 'Online (Zoom)',
    city: 'Online',
    description:
        'Stream the latest comebacks together, vote for the best choreography and chat with fans from around the world. Lightsticks are welcome even on camera.',
    dayOffset: 5,
    startHour: 20,
    durationHours: 2,
    ticketLink:
        'https://www.google.com/search?q=K-pop+comeback+listening+party',
  ),
  _EventSeed(
    id: 'demo_event_konoha_cosplay',
    fandom: 'Naruto',
    title: 'Konoha Cosplay Night',
    category: 'Cosplay',
    location: 'Expo Center, Karachi',
    city: 'Karachi',
    description:
        'Dress as your favourite shinobi and compete for the best Hokage, best Akatsuki and best group costume. Photo booths, a ramen stall and a Sharingan face-paint corner are included.',
    dayOffset: 6,
    startHour: 18,
    durationHours: 5,
    ticketLink: 'https://www.google.com/search?q=Naruto+cosplay+event',
  ),
  _EventSeed(
    id: 'demo_event_hawkins_dnd',
    fandom: 'Stranger Things',
    title: 'Hawkins D&D Campaign Night',
    category: 'Gaming',
    location: 'Board Game Lounge, Lahore',
    city: 'Lahore',
    description:
        'Join the Hellfire Club for a one-shot Dungeons & Dragons adventure inspired by the Upside Down. Beginners are welcome and character sheets are provided.',
    dayOffset: 7,
    startHour: 19,
    durationHours: 4,
  ),
  _EventSeed(
    id: 'demo_event_avengers_trivia',
    fandom: 'Marvel Cinematic Universe',
    title: 'Avengers Assemble Trivia Night',
    category: 'Quiz Night',
    location: 'The Hangout Cafe, Islamabad',
    city: 'Islamabad',
    description:
        'Form a team and test your MCU knowledge across all three phases of the Infinity Saga. The winning team takes home a mystery box of Marvel merchandise.',
    dayOffset: 9,
    startHour: 18,
    durationHours: 3,
  ),
  _EventSeed(
    id: 'demo_event_spidey_swap',
    fandom: 'Spider-Man',
    title: 'Spider-Verse Comic Swap Meet',
    category: 'Comic Swap',
    location: 'Comic Vault, Lahore',
    city: 'Lahore',
    description:
        'Trade, buy and sell Spider-Man comics, figures and posters with other collectors. A trading table for kids and a Miles Morales art wall make it a family-friendly afternoon.',
    dayOffset: 11,
    startHour: 14,
    durationHours: 5,
  ),
  _EventSeed(
    id: 'demo_event_mcu_marathon',
    fandom: 'Marvel Cinematic Universe',
    title: 'MCU Movie Marathon Weekend',
    category: 'Screening',
    location: 'Cinepax Hall 3, Lahore',
    city: 'Lahore',
    description:
        'Watch the first Avengers films back to back on the big screen with snacks, costume contests and a post-credits scene countdown between films.',
    dayOffset: 12,
    startHour: 12,
    durationHours: 10,
    ticketLink: 'https://www.google.com/search?q=Marvel+movie+marathon',
  ),
  _EventSeed(
    id: 'demo_event_sorting_night',
    fandom: 'Harry Potter',
    title: 'Hogwarts Sorting & Quidditch Trivia',
    category: 'Fan Meetup',
    location: 'Grand Hall, Lahore',
    city: 'Lahore',
    description:
        'Get sorted into your Hogwarts house, earn points in a magical trivia contest and try a muggle-friendly game of Quidditch.',
    dayOffset: 15,
    startHour: 16,
    durationHours: 4,
  ),
  _EventSeed(
    id: 'demo_event_kpop_dance',
    fandom: 'K-Pop',
    title: 'K-Pop Dance Cover Contest',
    category: 'Contest',
    location: 'Arts Auditorium, Karachi',
    city: 'Karachi',
    description:
        'Solo and group performers take the stage with their best K-Pop dance covers. Judges score choreography accuracy, stage presence and fan energy.',
    dayOffset: 18,
    startHour: 17,
    durationHours: 5,
    ticketLink: 'https://www.google.com/search?q=K-pop+dance+cover+contest',
  ),
  _EventSeed(
    id: 'demo_event_jedi_academy',
    fandom: 'Star Wars',
    title: 'Jedi Training Academy',
    category: 'Workshop',
    location: 'Community Hall, Karachi',
    city: 'Karachi',
    description:
        'Young padawans learn lightsaber forms, take the Jedi oath and take on a Sith trial. Kids are welcome, and light-up sabers are provided.',
    dayOffset: 20,
    startHour: 11,
    durationHours: 3,
  ),
  _EventSeed(
    id: 'demo_event_zelda_speedrun',
    fandom: 'The Legend of Zelda',
    title: 'Hyrule Speedrun Showdown',
    category: 'Tournament',
    location: 'Game Arena, Islamabad',
    city: 'Islamabad',
    description:
        'Race through Breath of the Wild challenges in a live bracket tournament. Spectators can cheer, vote for the best glitch and play in the free-play corner.',
    dayOffset: 25,
    startHour: 15,
    durationHours: 6,
    ticketLink: 'https://www.google.com/search?q=Zelda+speedrun+tournament',
  ),
  _EventSeed(
    id: 'demo_event_halloween',
    fandom: 'Stranger Things',
    title: 'Upside Down Halloween Party',
    category: 'Party',
    location: 'Rooftop Venue, Karachi',
    city: 'Karachi',
    description:
        'Come dressed as Eleven, Demogorgon or anyone from Hawkins for a 1980s-themed party with retro music, arcade games and a Mind Flayer photo booth.',
    dayOffset: 33,
    startHour: 20,
    durationHours: 5,
    ticketLink: 'https://www.google.com/search?q=Stranger+Things+party',
  ),
  _EventSeed(
    id: 'demo_event_zelda_orchestra',
    fandom: 'The Legend of Zelda',
    title: 'Zelda Orchestra Tribute Concert',
    category: 'Concert',
    location: 'Theatre Hall, Karachi',
    city: 'Karachi',
    description:
        'A live orchestral tribute to the music of Hyrule, from the classic overworld theme to modern Breath of the Wild pieces. Dress as Link or Zelda for a costume photo at the entrance.',
    dayOffset: 40,
    startHour: 19,
    durationHours: 3,
    ticketLink: 'https://www.google.com/search?q=Zelda+orchestra+concert',
  ),
  _EventSeed(
    id: 'demo_event_comic_con',
    fandom: 'Spider-Man',
    title: 'Fandom Verse Comic Con Weekend',
    category: 'Convention',
    location: 'Expo Center, Karachi',
    city: 'Karachi',
    description:
        'Two days of comics, cosplay, panels and a huge artist alley featuring Spider-Man, Marvel and anime fans. Meet artists, join workshops and shop for collectibles.',
    dayOffset: 45,
    startHour: 10,
    durationHours: 8,
    durationDays: 1,
    ticketLink: 'https://www.google.com/search?q=Comic+Con+Karachi',
  ),

  // ---------------- Past ----------------
  _EventSeed(
    id: 'demo_event_past_star_wars_day',
    fandom: 'Star Wars',
    title: 'Star Wars Day Fan Meetup',
    category: 'Fan Meetup',
    location: 'Community Hall, Karachi',
    city: 'Karachi',
    description:
        'Fans celebrated May the 4th with a costume parade, a lightsaber duel demo and a marathon of the original trilogy.',
    dayOffset: -145,
    startHour: 16,
    durationHours: 6,
  ),
  _EventSeed(
    id: 'demo_event_past_hp_night',
    fandom: 'Harry Potter',
    title: 'Harry Potter Book Night',
    category: 'Meetup',
    location: 'City Library, Islamabad',
    city: 'Islamabad',
    description:
        'A cosy reading night with costume prizes, a Sorting Hat ceremony and a butterbeer tasting.',
    dayOffset: -75,
    startHour: 18,
    durationHours: 3,
  ),
  _EventSeed(
    id: 'demo_event_past_spidey_cosplay',
    fandom: 'Spider-Man',
    title: 'Spider-Man Cosplay Meet',
    category: 'Cosplay',
    location: 'Fort View Park, Karachi',
    city: 'Karachi',
    description:
        'Fans gathered in their best Spider-Man suits, from classic Peter Parker to Spider-Verse variants, for photos and a group web-swing pose.',
    dayOffset: -60,
    startHour: 15,
    durationHours: 4,
  ),
  _EventSeed(
    id: 'demo_event_past_hokage_trivia',
    fandom: 'Naruto',
    title: 'Hokage Trivia Showdown',
    category: 'Quiz Night',
    location: 'Anime Cafe, Karachi',
    city: 'Karachi',
    description:
        'Naruto fans battled through rounds of jutsu, village and character trivia. Teams of four competed for the title of Hokage of the night.',
    dayOffset: -30,
    startHour: 18,
    durationHours: 3,
  ),
];

// ============================================================
// PRODUCT DEMO DATA (prices in PKR)
// Fan-inspired merchandise, one or more items per fandom.
// One item (Eleven's Waffle Mug) has stock 0 to demo "Out of stock".
// ============================================================

const List<_ProductSeed> _productSeeds = [
  // ---------------- Naruto ----------------
  _ProductSeed(
    'demo_product_akatsuki_hoodie',
    'Naruto',
    'Akatsuki Cloud Hoodie',
    'Clothing',
    4500,
    25,
    'A black zip hoodie with the iconic red cloud pattern. Soft fleece lining, perfect for cosplay nights and cold evenings.',
  ),
  _ProductSeed(
    'demo_product_konoha_headband',
    'Naruto',
    'Hidden Leaf Village Headband',
    'Accessories',
    1200,
    60,
    'A ninja headband with the Hidden Leaf symbol on a metal plate and an adjustable cloth strap.',
  ),
  _ProductSeed(
    'demo_product_naruto_figure',
    'Naruto',
    'Naruto Uzumaki Action Figure',
    'Toys',
    3800,
    15,
    'A poseable 18 cm collectible figure of Naruto in his orange jumpsuit, with a Rasengan effect piece.',
  ),
  _ProductSeed(
    'demo_product_naruto_manga',
    'Naruto',
    'Naruto Manga, Volume 1',
    'Books',
    1600,
    40,
    'The first volume of the manga where Naruto\'s journey to become Hokage begins.',
  ),

  // ---------------- Marvel Cinematic Universe ----------------
  _ProductSeed(
    'demo_product_arc_reactor',
    'Marvel Cinematic Universe',
    'Arc Reactor Desk Light',
    'Home',
    3200,
    18,
    'A glowing arc reactor style LED desk light with a USB cable. A great gift for any Iron Man fan.',
  ),
  _ProductSeed(
    'demo_product_avengers_tee',
    'Marvel Cinematic Universe',
    'Avengers Logo T-Shirt',
    'Clothing',
    2200,
    50,
    'A comfortable cotton t-shirt with the Avengers logo on the chest.',
  ),
  _ProductSeed(
    'demo_product_shield_mug',
    'Marvel Cinematic Universe',
    'Captain America Shield Mug',
    'Home',
    1400,
    35,
    'A ceramic 350 ml mug decorated with the classic star-and-stripes shield.',
  ),

  // ---------------- Star Wars ----------------
  _ProductSeed(
    'demo_product_lightsaber',
    'Star Wars',
    'LED Lightsaber Replica',
    'Toys',
    5500,
    12,
    'A light-up lightsaber with sound effects and a color-changing blade. Includes batteries.',
  ),
  _ProductSeed(
    'demo_product_falcon_set',
    'Star Wars',
    'Millennium Falcon Building Set',
    'Toys',
    9800,
    6,
    'A detailed brick-style model of the legendary ship with a removable cockpit and mini crew figures.',
  ),
  _ProductSeed(
    'demo_product_rebel_cap',
    'Star Wars',
    'Rebel Alliance Cap',
    'Accessories',
    1500,
    30,
    'An adjustable baseball cap with an embroidered Rebel Alliance starbird.',
  ),

  // ---------------- Harry Potter ----------------
  _ProductSeed(
    'demo_product_house_scarf',
    'Harry Potter',
    'Hogwarts House Scarf',
    'Accessories',
    2400,
    40,
    'A warm striped knit scarf in house colors. Perfect for Quidditch season.',
  ),
  _ProductSeed(
    'demo_product_wand',
    'Harry Potter',
    'Wizard Wand Replica',
    'Toys',
    2800,
    25,
    'A hand-painted wand replica in a collector\'s box. It is only missing the magic.',
  ),
  _ProductSeed(
    'demo_product_hp_book_set',
    'Harry Potter',
    'Complete Book Set (7 Books)',
    'Books',
    12500,
    8,
    'All seven Harry Potter books in a matching boxed set, from the Philosopher\'s Stone to the Deathly Hallows.',
  ),

  // ---------------- The Legend of Zelda ----------------
  _ProductSeed(
    'demo_product_master_sword',
    'The Legend of Zelda',
    'Master Sword Replica',
    'Accessories',
    6500,
    10,
    'A 60 cm display replica of the Master Sword with a wall stand.',
  ),
  _ProductSeed(
    'demo_product_triforce',
    'The Legend of Zelda',
    'Triforce Pendant Necklace',
    'Accessories',
    1800,
    45,
    'A gold-tone Triforce pendant on a stainless steel chain.',
  ),
  _ProductSeed(
    'demo_product_zelda_poster',
    'The Legend of Zelda',
    'Hyrule Landscape Poster',
    'Home',
    900,
    70,
    'A large glossy poster of a Hyrule landscape with the castle in the distance.',
  ),

  // ---------------- Stranger Things ----------------
  _ProductSeed(
    'demo_product_hellfire_tee',
    'Stranger Things',
    'Hellfire Club T-Shirt',
    'Clothing',
    2300,
    35,
    'A black t-shirt with a flaming skull print inspired by the Hellfire Club.',
  ),
  _ProductSeed(
    'demo_product_waffle_mug',
    'Stranger Things',
    'Eleven\'s Waffle Mug',
    'Home',
    1300,
    0,
    'A breakfast mug for waffle lovers everywhere. Currently sold out.',
  ),
  _ProductSeed(
    'demo_product_walkie_talkie',
    'Stranger Things',
    'Retro Walkie-Talkie Set',
    'Electronics',
    4900,
    14,
    'A pair of retro-style walkie-talkies with a 3 km range. Perfect for your own Hawkins adventure.',
  ),

  // ---------------- K-Pop ----------------
  _ProductSeed(
    'demo_product_lightstick',
    'K-Pop',
    'Fan Light Stick',
    'Electronics',
    6200,
    20,
    'A bluetooth light stick with multiple color modes. Bring it to every concert and listening party.',
  ),
  _ProductSeed(
    'demo_product_photocard_album',
    'K-Pop',
    'Photocard Collector Album',
    'Accessories',
    1500,
    55,
    'A 4x6 binder album with 40 pockets for your photocards.',
  ),
  _ProductSeed(
    'demo_product_kpop_headphones',
    'K-Pop',
    'Wireless Headphones',
    'Electronics',
    7800,
    9,
    'Over-ear bluetooth headphones with noise cancelling and 30 hours of battery, ready for your playlists.',
  ),

  // ---------------- Spider-Man ----------------
  _ProductSeed(
    'demo_product_web_shooter',
    'Spider-Man',
    'Web-Shooter Toy',
    'Toys',
    2500,
    30,
    'A wrist-mounted web-shooter toy with soft foam darts. Great for young heroes.',
  ),
  _ProductSeed(
    'demo_product_spidey_sneakers',
    'Spider-Man',
    'Spider-Verse Sneakers',
    'Shoes',
    11500,
    12,
    'Street-style high-top sneakers with a bold graffiti and web design, inspired by the Spider-Verse.',
  ),
  _ProductSeed(
    'demo_product_spiderverse_novel',
    'Spider-Man',
    'Spider-Verse Graphic Novel',
    'Books',
    2900,
    22,
    'A collected graphic novel following Spider-heroes from across the multiverse.',
  ),
];