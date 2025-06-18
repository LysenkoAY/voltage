library;

import 'package:flutter/material.dart';

class VoltageHomePage extends StatefulWidget {
  const VoltageHomePage({super.key});

  @override
  State<VoltageHomePage> createState() => _VoltageHomePageState();
}

class _VoltageHomePageState extends State<VoltageHomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _headerKeys = List.generate(3, (_) => GlobalKey());
  final List<double> _sectionPositions = [];
  String _currentSectionTitle = 'Section 1';
  final double expandedHeight = 200;
  final double collapsedHeight = kToolbarHeight;

  // Состояния AppBar
  bool _isFullyExpanded = true;
  bool _isFullyCollapsed = false;
  bool _isExpanding = false;
  bool _isCollapsing = false;

  // Последнее известное положение скролла
  double _lastOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateSectionPositions());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  void _calculateSectionPositions() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final scrollViewPosition = renderBox.localToGlobal(Offset.zero);

    for (final key in _headerKeys) {
      final context = key.currentContext;
      if (context == null) continue;

      final box = context.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final headerPosition = box.localToGlobal(Offset.zero);
      final positionFromTop = headerPosition.dy - scrollViewPosition.dy;
      _sectionPositions.add(positionFromTop);
    }
  }

  void _scrollListener() {
    if (_sectionPositions.isEmpty || !_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    //-----------------------------------------------------------------------------------------------------------------
    final double scrollDelta = offset - _lastOffset;
    final bool isScrollingUp = scrollDelta < 0;
    final bool isScrollingDown = scrollDelta > 0;

    // Пороги для определения состояний
    const double threshold = 5.0; // Небольшой порог для определения начала движения
    final double fullyExpandedThreshold = 5.0;
    final double fullyCollapsedThreshold = expandedHeight - collapsedHeight - 5.0;

    // Определение состояний
    if (isScrollingDown && offset > fullyExpandedThreshold && _isFullyExpanded) {
      setState(() {
        _isFullyExpanded = false;
        _isCollapsing = true;
      });

      debugPrint('SliverAppBar начал сворачиваться');
    }

    if (isScrollingUp && offset < fullyCollapsedThreshold && _isFullyCollapsed) {
      setState(() {
        _isFullyCollapsed = false;
        _isExpanding = true;
      });

      debugPrint('SliverAppBar начал разворачиваться');
    }

    if (offset <= fullyExpandedThreshold && !_isFullyExpanded) {
      setState(() {
        _isFullyExpanded = true;
        _isExpanding = false;
      });

      debugPrint('SliverAppBar полностью развернут');
    }

    if (offset >= fullyCollapsedThreshold && !_isFullyCollapsed) {
      setState(() {
        _isFullyCollapsed = true;
        _isCollapsing = false;
      });

      debugPrint('SliverAppBar полностью свернут');
    }

    _lastOffset = offset;
    //-----------------------------------------------------------------------------------------------------------------
    String newTitle = _currentSectionTitle;

    for (int i = _sectionPositions.length - 1; i >= 0; i--) {
      final headerTop = _sectionPositions[i] - offset;
      if (headerTop <= collapsedHeight) {
      //ToDo  newTitle = sectionTitles[i];
        break;
      }
    }

    if (newTitle != _currentSectionTitle) {
      setState(() => _currentSectionTitle = newTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
