import 'package:flutter/material.dart';
import 'dart:io';
import 'favorites_screen.dart';
import '../widgets/plant_info_card.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';
import '../services/favorites_service.dart';
import '../services/model_service.dart';
import '../services/storage_service.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _imagePath;
  String? _plantName;
  String? _plantDescription;
  final ImagePicker _picker = ImagePicker();
  bool _isIdentifying = false;
  List<String> _labels = [];
  double? _confidence;

  // Comprehensive plant information mapping (add more as needed)
  final Map<String, Map<String, String>> _plantInfo = {
    'Aloevera': {
      "name": "Aloe Vera",
    "description": "Aloe Vera is a succulent plant species widely recognized for its medicinal and cosmetic applications. It has thick, fleshy leaves filled with a gel-like substance that offers several therapeutic benefits.",
    "uses": "Used to soothe burns and wounds, moisturize skin, and improve digestion. Also used in treating acne and dandruff.",
    "more_info": "Aloe Vera thrives in warm climates and requires minimal care. It is rich in vitamins A, C, E, and B12, enzymes, and amino acids. Its gel is often used in skin care products and health drinks."
    },
    'Amla': {
      "name": "Amla (Indian Gooseberry)",
    "description": "Amla is a nutrient-rich fruit high in Vitamin C and antioxidants, revered in Ayurveda for its rejuvenating properties. It supports overall health and longevity.",
    "uses": "Improves immunity, aids digestion, enhances hair health, and promotes liver detoxification. Also beneficial for heart health.",
    "more_info": "Amla can be consumed raw, as juice, or in dried form. It is a primary ingredient in Ayurvedic formulations like Triphala and Chyawanprash, promoting vitality and youthfulness."
    },
    'Amruta_Balli': {
      'name': 'Amruta Balli (Giloy/Tinospora Cordifolia)',
    "description": "Amruta Balli, also known as Giloy, is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to treat respiratory issues, improve digestion, and boost immunity. Also helps in reducing inflammation and promoting overall well-being.",
    "more_info": "Amruta Balli is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Arali': {
      'name': 'Arali',
    "description": "Arali, also known as Indian Ginseng, is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Arali is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Ashoka': {
      'name': 'Ashoka',
    "description": "Ashoka is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Ashoka is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Ashwagandha': {
      'name': 'Ashwagandha',
    "description": "Ashwagandha is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Ashwagandha is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Avacado': {
      'name': 'Avacado',
    "description": "Avacado is a fruit that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Avacado is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Bamboo': {
      'name': 'Bamboo',
    "description": "Bamboo is a woody perennial grass that is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Bamboo is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Basale': {
      'name': 'Basale',
    "description": "Basale is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Basale is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Betel': {
      'name': 'Betel',
    "description": "Betel is a plant that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Betel is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Betel_Nut': {
      'name': 'Betel Nut',
    "description": "Betel Nut is a plant that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Betel Nut is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Brahmi': {
      'name': 'Brahmi',
    "description": "Brahmi is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Brahmi is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Castor': {
      'name': 'Castor',
    "description": "Castor is a plant that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Castor is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Curry_Leaf': {
      'name': 'Curry Leaf',
    "description": "Curry Leaf is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Curry Leaf is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Doddapatre': {
      'name': 'Doddapatre',
    "description": "Doddapatre is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Doddapatre is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Ekka': {
      'name': 'Ekka',
    "description": "Ekka is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Ekka is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Ganike': {
      'name': 'Ganike',
    "description": "Ganike is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Ganike is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Gauva': {
      'name': 'Gauva',
    "description": "Gauva is a fruit that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Gauva is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Geranium': {
      'name': 'Geranium',
    "description": "Geranium is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Geranium is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Henna': {
      'name': 'Henna',
    "description": "Henna is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Henna is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Hibiscus': {
      'name': 'Hibiscus',
    "description": "Hibiscus is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Hibiscus is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Honge': {
      'name': 'Honge',
    "description": "Honge is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Honge is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Insulin': {
      'name': 'Insulin Plant',
    "description": "Insulin Plant is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Insulin Plant is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Jasmine': {
      'name': 'Jasmine',
    "description": "Jasmine is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Jasmine is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Lemon': {
      'name': 'Lemon',
    "description": "Lemon is a fruit that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Lemon is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Lemon_grass': {
      'name': 'Lemon Grass',
    "description": "Lemon Grass is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Lemon Grass is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Mango': {
      'name': 'Mango',
    "description": "Mango is a fruit that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Mango is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Mint': {
      'name': 'Mint',
    "description": "Mint is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Mint is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Nagadali': {
      'name': 'Nagadali',
    "description": "Nagadali is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Nagadali is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Neem': {
      'name': 'Neem',
    "description": "Neem is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Neem is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Nithyapushpa': {
      'name': 'Nithyapushpa',
    "description": "Nithyapushpa is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Nithyapushpa is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Nooni': {
      'name': 'Nooni',
    "description": "Nooni is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Nooni is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Pappaya': {
      'name': 'Pappaya',
    "description": "Pappaya is a fruit that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Pappaya is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Pepper': {
      'name': 'Pepper',
    "description": "Pepper is a spice that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Pepper is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Pomegranate': {
      'name': 'Pomegranate',
    "description": "Pomegranate is a fruit that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Pomegranate is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Raktachandini': {
      'name': 'Raktachandini',
    "description": "Raktachandini is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Raktachandini is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Rose': {
      'name': 'Rose',
    "description": "Rose is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Rose is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Sapota': {
      'name': 'Sapota',
    "description": "Sapota is a fruit that is rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Sapota is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Tulasi': {
      'name': 'Tulasi (Holy Basil)',
    "description": "Tulasi is a sacred plant in India, known for its medicinal and spiritual significance. It is used to treat colds, inflammation, and stress.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Tulasi is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
    'Wood_sorel': {
      'name': 'Wood Sorel',
    "description": "Wood Sorel is a medicinal herb with roots that are rich in antioxidants and anti-inflammatory properties. It is widely used in Ayurveda for its health benefits.",
    "uses": "Used to improve energy levels, boost immunity, and reduce stress. Also helps in treating fatigue and improving cognitive function.",
    "more_info": "Wood Sorel is known for its adaptogenic properties, making it suitable for both acute and chronic health conditions."
    },
  };

  @override
  void initState() {
    super.initState();
    _loadLabels();
  }

  Future<void> _loadLabels() async {
    final labelsString = await rootBundle.loadString('assets/labels.txt');
    setState(() {
      _labels = labelsString.split('\n').where((l) => l.trim().isNotEmpty).toList();
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritesScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Identifier'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {
                                        _imagePath = image.path;
                                        _plantName = null;
                                        _plantDescription = null;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Choose from Device'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                    if (image != null) {
                                      setState(() {
                                        _imagePath = image.path;
                                        _plantName = null;
                                        _plantDescription = null;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Capture Image'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _imagePath == null || _isIdentifying ? null : () async {
                              setState(() { _isIdentifying = true; });
                              try {
                                final tflite = TFLiteService();
                                final result = await tflite.runInference(File(_imagePath!));
                                final predictedIdx = result['index'] as int;
                                final confidence = result['confidence'] as double;

                                print('Labels:  _labels');
                                print('Predicted index: $predictedIdx');
                                print('Label at index: ${_labels.isNotEmpty && predictedIdx >= 0 && predictedIdx < _labels.length ? _labels[predictedIdx] : "Out of bounds"}');
                                print('Confidence: ${confidence * 100}%');

                                String plantName = 'Unknown Plant';
                                if (_labels.isNotEmpty && predictedIdx >= 0 && predictedIdx < _labels.length) {
                                  plantName = _labels[predictedIdx];
                                }
                                final plantDesc = _plantInfo[plantName] ?? 'No details available for this plant.';
                                setState(() {
                                  _plantName = plantName;
                                  _confidence = confidence;
                                  _isIdentifying = false;
                                });
                              } catch (e) {
                                setState(() {
                                  _plantName = 'Error';
                                  _plantDescription = 'Failed to identify plant. Please try again with a different image.';
                                  _confidence = null;
                                  _isIdentifying = false;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isIdentifying)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  const Icon(Icons.search),
                                const SizedBox(width: 8),
                                Text(_isIdentifying ? 'Identifying...' : 'Identify Plant'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_plantName != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: 250, // Adjust as needed
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Builder(
                                builder: (context) {
                                  final info = _plantInfo[_plantName!];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        info?['name'] ?? _plantName!,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      if (_confidence != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            'Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        info?['description'] ?? 'No details available for this plant.',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      if (info?['uses'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text('Uses:  ${info!['uses']}'),
                                        ),
                                      if (info?['more_info'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text('More Info: ${info!['more_info']}'),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}