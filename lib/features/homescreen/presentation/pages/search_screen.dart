import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ai_shopping_assistant/core/constants/app_colors.dart';
import '../bloc/search_cubit.dart';
import '../../domain/entities/product_entity.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatelessWidget {
  final bool initialVoiceSearch;

  const SearchScreen({super.key, this.initialVoiceSearch = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: _SearchScreenView(initialVoiceSearch: initialVoiceSearch),
    );
  }
}

class _SearchScreenView extends StatefulWidget {
  final bool initialVoiceSearch;

  const _SearchScreenView({this.initialVoiceSearch = false});

  @override
  State<_SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends State<_SearchScreenView> {
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        setState(() => _isListening = false);
      },
    );

    if (widget.initialVoiceSearch) {
      _startVoiceSearch();
    }
  }

  void _startVoiceSearch() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available on this device.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
        });
        if (result.finalResult) {
          _performSearch(_searchController.text);
        }
      },
    );
  }

  void _stopVoiceSearch() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchCubit>().searchProducts(query);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: !widget.initialVoiceSearch,
          decoration: const InputDecoration(
            hintText: 'Search for products...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16),
          ),
          onSubmitted: _performSearch,
          onChanged: (val) {
            // Optional: debounce live search here if desired.
          },
        ),
        actions: [
          IconButton(
            icon: _isListening
                ? const Icon(Icons.mic, color: AppColors.red)
                : const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary),
            onPressed: () {
              if (_isListening) {
                _stopVoiceSearch();
              } else {
                _startVoiceSearch();
              }
            },
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              onPressed: () {
                _searchController.clear();
                context.read<SearchCubit>().searchProducts('');
                setState(() {});
              },
            ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            );
          }
          if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          if (state is SearchLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text(
                  'No products found.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) => _SearchProductCard(product: state.products[index]),
            );
          }

          // Initial State (No search yet)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.search,
                  size: 80,
                  color: _isListening ? AppColors.red.withValues(alpha: 0.5) : AppColors.textSecondary.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  _isListening ? 'Listening for your search...' : 'Type to search for products, meals, and more.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  final ProductEntity product;
  const _SearchProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            color: AppColors.netural,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Color.fromARGB(255, 61, 72, 109),
                            ),
                          ),
                        )
                      : Container(
                          height: 120,
                          color: AppColors.netural,
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.textSecondary,
                            size: 40,
                          ),
                        ),
                ),
                if (product.hasOffer)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'OFFER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.finalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
