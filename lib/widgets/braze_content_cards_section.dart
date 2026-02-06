import 'package:braze_plugin/braze_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_cards_provider.dart';
import '../services/braze_service.dart';
import '../utils/theme.dart';

/// Renders Braze Content Cards in a horizontal list directly under the Limited time offer on the home screen.
class BrazeContentCardsSection extends StatelessWidget {
  const BrazeContentCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentCardsProvider>(
      builder: (context, provider, _) {
        final cards = provider.displayCards;
        if (cards.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final card = cards[index];
                return _ContentCardTile(
                  card: card,
                  onTap: () {
                    BrazeService.logContentCardClicked(card);
                    if (card.url.isNotEmpty) {
                      // Optional: url_launcher or in-app browser
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ContentCardTile extends StatefulWidget {
  const _ContentCardTile({required this.card, required this.onTap});

  final BrazeContentCard card;
  final VoidCallback onTap;

  @override
  State<_ContentCardTile> createState() => _ContentCardTileState();
}

class _ContentCardTileState extends State<_ContentCardTile> {
  bool _impressionLogged = false;

  @override
  Widget build(BuildContext context) {
    if (!_impressionLogged) {
      _impressionLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BrazeService.logContentCardImpression(widget.card);
      });
    }

    final card = widget.card;
    final hasImage = card.image.isNotEmpty;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasImage)
                  SizedBox(
                    width: 100,
                    child: CachedNetworkImage(
                      imageUrl: card.image,
                      fit: BoxFit.cover,
                      httpHeaders: const {'User-Agent': 'VeryGoodBurgers/1.0'},
                      placeholder: (_, __) => Container(
                        color: AppColors.gray200,
                        child: const Center(
                          child: Icon(Icons.image_outlined, color: AppColors.gray400, size: 28),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.gray200,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined, color: AppColors.gray400, size: 28),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (card.title.isNotEmpty)
                          Text(
                            card.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (card.title.isNotEmpty && card.description.isNotEmpty) const SizedBox(height: 4),
                        if (card.description.isNotEmpty)
                          Text(
                            card.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray700,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (card.linkText.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            card.linkText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
