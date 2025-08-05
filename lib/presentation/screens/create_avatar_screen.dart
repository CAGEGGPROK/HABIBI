import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../data/models/user_model.dart';
import '../../data/storage/user_storage.dart';
import '../../services/avatar_service.dart';
import '../../services/stats_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/realistic_3d_character.dart';

/// Экран создания и кастомизации персонажа
class CreateAvatarScreen extends StatefulWidget {
  const CreateAvatarScreen({super.key});

  @override
  State<CreateAvatarScreen> createState() => _CreateAvatarScreenState();
}

class _CreateAvatarScreenState extends State<CreateAvatarScreen> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  late AnimationController _rotationController;
  
  // Состояние персонажа
  bool _isCreatingUser = false;
  double _characterRotation = 0;
  
  // Параметры кастомизации
  CharacterCustomization _customization = CharacterCustomization();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.surfaceVariant.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Создание персонажа',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Персонаж
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // 3D персонаж
                    Center(
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _characterRotation += details.delta.dx * 0.01;
                          });
                        },
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(_characterRotation),
                          child: Realistic3DCharacter(
                            customization: _customization,
                            size: MediaQuery.of(context).size.width * 0.6,
                            rotationY: _characterRotation,
                          ),
                        ),
                      ),
                    ),
                    
                    // Кнопки поворота
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.rotate_left_rounded),
                          onPressed: () {
                            setState(() {
                              _characterRotation -= math.pi / 4;
                            });
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.rotate_right_rounded),
                          onPressed: () {
                            setState(() {
                              _characterRotation += math.pi / 4;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Панель кастомизации
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Табы категорий
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(icon: Icon(Icons.person), text: 'Тело'),
                          Tab(icon: Icon(Icons.face), text: 'Лицо'),
                          Tab(icon: Icon(Icons.palette), text: 'Кожа'),
                          Tab(icon: Icon(Icons.face_retouching_natural), text: 'Волосы'),
                          Tab(icon: Icon(Icons.visibility), text: 'Глаза'),
                          Tab(icon: Icon(Icons.checkroom), text: 'Одежда'),
                          Tab(icon: Icon(Icons.auto_awesome), text: 'Аксессуары'),
                          Tab(icon: Icon(Icons.person_outline), text: 'Имя'),
                        ],
                      ),
                      
                      // Контент табов
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildBodyCustomization(),
                            _buildFaceCustomization(),
                            _buildSkinCustomization(),
                            _buildHairCustomization(),
                            _buildEyesCustomization(),
                            _buildClothingCustomization(),
                            _buildAccessoriesCustomization(),
                            _buildNameInput(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Кнопка создания
      floatingActionButton: _tabController.index == 7
          ? FloatingActionButton.extended(
              onPressed: _isCreatingUser ? null : _createUser,
              backgroundColor: AppColors.primary,
              icon: _isCreatingUser
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isCreatingUser ? 'Создание...' : 'Создать персонажа'),
            )
          : null,
    );
  }
  
  /// Кастомизация тела
  Widget _buildBodyCustomization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSlider(
            label: 'Рост',
            value: _customization.height,
            onChanged: (value) {
              setState(() {
                _customization.height = value;
              });
            },
          ),
          _buildSlider(
            label: 'Телосложение',
            value: _customization.bodyBuild,
            onChanged: (value) {
              setState(() {
                _customization.bodyBuild = value;
              });
            },
            labels: const ['Худое', 'Среднее', 'Крупное'],
          ),
          _buildSlider(
            label: 'Размер головы',
            value: _customization.headSize,
            onChanged: (value) {
              setState(() {
                _customization.headSize = value;
              });
            },
          ),
          _buildSlider(
            label: 'Длина рук',
            value: _customization.armLength,
            onChanged: (value) {
              setState(() {
                _customization.armLength = value;
              });
            },
          ),
          _buildSlider(
            label: 'Длина ног',
            value: _customization.legLength,
            onChanged: (value) {
              setState(() {
                _customization.legLength = value;
              });
            },
          ),
          _buildSlider(
            label: 'Ширина плеч',
            value: _customization.shoulderWidth,
            onChanged: (value) {
              setState(() {
                _customization.shoulderWidth = value;
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// Кастомизация лица
  Widget _buildFaceCustomization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOptionSelector(
            label: 'Форма лица',
            options: ['Овальное', 'Круглое', 'Квадратное', 'Треугольное', 'Сердцевидное'],
            selected: _customization.faceShape,
            onSelected: (value) {
              setState(() {
                _customization.faceShape = value;
              });
            },
          ),
          _buildOptionSelector(
            label: 'Форма носа',
            options: ['Прямой', 'Курносый', 'Орлиный', 'Широкий', 'Узкий'],
            selected: _customization.noseShape,
            onSelected: (value) {
              setState(() {
                _customization.noseShape = value;
              });
            },
          ),
          _buildOptionSelector(
            label: 'Форма губ',
            options: ['Тонкие', 'Средние', 'Пухлые', 'В форме сердца'],
            selected: _customization.lipsShape,
            onSelected: (value) {
              setState(() {
                _customization.lipsShape = value;
              });
            },
          ),
          _buildOptionSelector(
            label: 'Подбородок',
            options: ['Острый', 'Круглый', 'Квадратный', 'С ямочкой'],
            selected: _customization.chinShape,
            onSelected: (value) {
              setState(() {
                _customization.chinShape = value;
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// Кастомизация кожи
  Widget _buildSkinCustomization() {
    final skinTones = [
      const Color(0xFFFFDFC4), // Очень светлая
      const Color(0xFFF0DDD7), // Светлая
      const Color(0xFFE8CDA9), // Средняя светлая
      const Color(0xFFDFAE8F), // Средняя
      const Color(0xFFD29D7E), // Средняя темная
      const Color(0xFFB57C5C), // Темная
      const Color(0xFF8D5A3C), // Очень темная
      const Color(0xFF5A3A29), // Экстра темная
      
      // Фантазийные цвета
      const Color(0xFFE8B4FF), // Фиолетовый
      const Color(0xFFB4E8FF), // Голубой
      const Color(0xFFB4FFB4), // Зеленый
      const Color(0xFFFFB4B4), // Розовый
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Цвет кожи',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: skinTones.length,
            itemBuilder: (context, index) {
              final color = skinTones[index];
              final isSelected = _customization.skinColor == color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _customization.skinColor = color;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 32,
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// Кастомизация волос
  Widget _buildHairCustomization() {
    final hairColors = [
      Colors.black,
      Colors.brown.shade900,
      Colors.brown.shade700,
      Colors.brown.shade500,
      Colors.orange.shade800,
      Colors.orange.shade600,
      Colors.yellow.shade700,
      Colors.grey.shade400,
      Colors.grey.shade300,
      Colors.white,
      
      // Яркие цвета
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.teal,
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionSelector(
            label: 'Прическа',
            options: ['Короткая', 'Средняя', 'Длинная', 'Лысый', 'Ирокез', 'Хвост', 'Пучок', 'Дреды'],
            selected: _customization.hairStyle,
            onSelected: (value) {
              setState(() {
                _customization.hairStyle = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Цвет волос',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: hairColors.length,
            itemBuilder: (context, index) {
              final color = hairColors[index];
              final isSelected = _customization.hairColor == color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _customization.hairColor = color;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildOptionSelector(
            label: 'Растительность на лице',
            options: ['Нет', 'Усы', 'Борода', 'Бакенбарды', 'Эспаньолка', 'Полная борода'],
            selected: _customization.facialHair,
            onSelected: (value) {
              setState(() {
                _customization.facialHair = value;
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// Кастомизация глаз
  Widget _buildEyesCustomization() {
    final eyeColors = [
      Colors.brown.shade800,
      Colors.brown.shade600,
      Colors.green.shade700,
      Colors.blue.shade600,
      Colors.grey.shade600,
      Colors.amber.shade700,
      
      // Фантазийные
      Colors.purple,
      Colors.red,
      Colors.pink,
      Colors.cyan,
      Colors.indigo,
      Colors.orange,
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOptionSelector(
            label: 'Форма глаз',
            options: ['Миндалевидные', 'Круглые', 'Узкие', 'Широкие', 'Опущенные уголки', 'Поднятые уголки'],
            selected: _customization.eyeShape,
            onSelected: (value) {
              setState(() {
                _customization.eyeShape = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Цвет глаз',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: eyeColors.length,
            itemBuilder: (context, index) {
              final color = eyeColors[index];
              final isSelected = _customization.eyeColor == color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _customization.eyeColor = color;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        color,
                        color.withOpacity(0.6),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// Кастомизация одежды
  Widget _buildClothingCustomization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOptionSelector(
            label: 'Стиль одежды',
            options: ['Повседневный', 'Спортивный', 'Деловой', 'Вечерний', 'Уличный', 'Фэнтези'],
            selected: _customization.clothingStyle,
            onSelected: (value) {
              setState(() {
                _customization.clothingStyle = value;
              });
            },
          ),
          _buildOptionSelector(
            label: 'Верх',
            options: ['Футболка', 'Рубашка', 'Свитер', 'Худи', 'Майка', 'Пиджак'],
            selected: _customization.topClothing,
            onSelected: (value) {
              setState(() {
                _customization.topClothing = value;
              });
            },
          ),
          _buildOptionSelector(
            label: 'Низ',
            options: ['Джинсы', 'Брюки', 'Шорты', 'Юбка', 'Спортивные штаны'],
            selected: _customization.bottomClothing,
            onSelected: (value) {
              setState(() {
                _customization.bottomClothing = value;
              });
            },
          ),
          _buildOptionSelector(
            label: 'Обувь',
            options: ['Кроссовки', 'Ботинки', 'Туфли', 'Сандалии', 'Босиком'],
            selected: _customization.shoes,
            onSelected: (value) {
              setState(() {
                _customization.shoes = value;
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// Кастомизация аксессуаров
  Widget _buildAccessoriesCustomization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMultiSelector(
            label: 'Аксессуары',
            options: [
              'Очки',
              'Солнцезащитные очки',
              'Серьги',
              'Ожерелье',
              'Часы',
              'Браслет',
              'Шляпа',
              'Кепка',
              'Шарф',
              'Перчатки',
            ],
            selected: _customization.accessories,
            onChanged: (value, isSelected) {
              setState(() {
                if (isSelected) {
                  _customization.accessories.add(value);
                } else {
                  _customization.accessories.remove(value);
                }
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// Ввод имени
  Widget _buildNameInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Icon(
              Icons.badge_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Как зовут вашего персонажа?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Имя персонажа',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите имя персонажа';
                }
                if (value.trim().length < 2) {
                  return 'Минимум 2 символа';
                }
                if (value.trim().length > 20) {
                  return 'Максимум 20 символов';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Слайдер для настройки параметров
  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    List<String>? labels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        if (labels != null && labels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.map((label) => Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )).toList(),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  /// Селектор опций
  Widget _buildOptionSelector({
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  /// Мультиселектор
  Widget _buildMultiSelector({
    required String label,
    required List<String> options,
    required List<String> selected,
    required Function(String, bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (value) => onChanged(option, value),
              selectedColor: AppColors.primary.withOpacity(0.2),
              backgroundColor: AppColors.surfaceVariant,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// Создание пользователя
  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      // Переключаемся на таб с именем
      _tabController.animateTo(7);
      return;
    }
    
    setState(() {
      _isCreatingUser = true;
    });
    
    try {
      // Создаем пользователя с кастомизацией
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        avatarPath: '',
        gender: _customization.gender,
        createdAt: DateTime.now(),
      );
      
      // Сохраняем кастомизацию отдельно
      await _saveCustomization(user.id);
      
      // Сохраняем пользователя
      await UserStorage.saveUser(user);
      
      // Инициализируем статистику
      final statsService = context.read<StatsService>();
      await statsService.initializeStats(user.id);
      
      // Переходим на главный экран
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при создании персонажа: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreatingUser = false;
      });
    }
  }
  
  /// Сохранение кастомизации
  Future<void> _saveCustomization(String userId) async {
    // Здесь можно сохранить кастомизацию в Hive
    // Для примера просто сохраним в переменную
    print('Сохранение кастомизации для пользователя $userId');
  }
}

/// Модель кастомизации персонажа
class CharacterCustomization {
  // Пол
  String gender = 'male';
  
  // Параметры тела
  double height = 0.5;
  double bodyBuild = 0.5;
  double headSize = 0.5;
  double armLength = 0.5;
  double legLength = 0.5;
  double shoulderWidth = 0.5;
  
  // Лицо
  String faceShape = 'Овальное';
  String noseShape = 'Прямой';
  String lipsShape = 'Средние';
  String chinShape = 'Круглый';
  
  // Кожа
  Color skinColor = const Color(0xFFE8CDA9);
  
  // Волосы
  String hairStyle = 'Короткая';
  Color hairColor = Colors.brown.shade800;
  String facialHair = 'Нет';
  
  // Глаза
  String eyeShape = 'Миндалевидные';
  Color eyeColor = Colors.brown.shade600;
  
  // Одежда
  String clothingStyle = 'Повседневный';
  String topClothing = 'Футболка';
  String bottomClothing = 'Джинсы';
  String shoes = 'Кроссовки';
  
  // Аксессуары
  List<String> accessories = [];
}