import 'package:flutter/material.dart';
import 'services/dynamic_icon_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Logo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DynamicIconDemo(),
    );
  }
}

class DynamicIconDemo extends StatefulWidget {
  const DynamicIconDemo({super.key});

  @override
  State<DynamicIconDemo> createState() => _DynamicIconDemoState();
}

class _DynamicIconDemoState extends State<DynamicIconDemo> {
  final DynamicIconService _iconService = DynamicIconService();
  String? _currentIconName;
  bool _isLoading = false;
  bool _isSupported = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentIcon();
  }

  Future<void> _loadCurrentIcon() async {
    final isSupported = await _iconService.isSupported();
    final currentIcon = await _iconService.getCurrentIconName();
    setState(() {
      _isSupported = isSupported;
      _currentIconName = currentIcon;
    });
  }

  Future<void> _changeIcon(AppIconType iconType) async {
    setState(() => _isLoading = true);

    final success = await _iconService.setIcon(iconType);

    if (success) {
      await _loadCurrentIcon();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã đổi icon thành: ${_iconService.getIconDisplayName(iconType)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đổi icon. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _autoSetIcon() async {
    setState(() => _isLoading = true);
    await _iconService.autoSetIconByDate();
    await _loadCurrentIcon();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tự động đổi icon theo ngày hiện tại!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic App Icon'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.app_shortcut,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Icon hiện tại',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentIconName ?? 'Mặc định',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    if (!_isSupported) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '⚠️ Thiết bị này không hỗ trợ đổi icon động',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Chọn icon theo sự kiện',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Icon Options
            _IconOptionCard(
              title: 'Mặc định',
              subtitle: 'Icon tiêu chuẩn của ứng dụng',
              icon: Icons.home,
              color: Colors.deepPurple,
              isLoading: _isLoading,
              isSelected: _currentIconName == null,
              onTap: () => _changeIcon(AppIconType.defaultIcon),
            ),

            const SizedBox(height: 12),

            _IconOptionCard(
              title: 'Tết Nguyên Đán 🧧',
              subtitle: 'Bao lì xì, hoa mai - Chúc mừng năm mới!',
              icon: Icons.celebration,
              color: Colors.red,
              isLoading: _isLoading,
              isSelected: _currentIconName == 'tet_icon',
              onTap: () => _changeIcon(AppIconType.tet),
            ),

            const SizedBox(height: 12),

            _IconOptionCard(
              title: 'Giáng Sinh 🎄',
              subtitle: 'Cây thông, quà tặng - Merry Christmas!',
              icon: Icons.park,
              color: Colors.green,
              isLoading: _isLoading,
              isSelected: _currentIconName == 'christmas_icon',
              onTap: () => _changeIcon(AppIconType.christmas),
            ),

            const SizedBox(height: 32),

            // Auto Set Button
            FilledButton.icon(
              onPressed: _isLoading ? null : _autoSetIcon,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Tự động đổi theo ngày'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lưu ý',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Trên iOS: Hệ thống sẽ hỏi xác nhận trước khi đổi icon\n'
                      '• Trên Android: Ứng dụng có thể khởi động lại khi đổi icon\n'
                      '• Icon mới sẽ xuất hiện trên màn hình chính sau khi đổi',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 28)
              else if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.outline,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
