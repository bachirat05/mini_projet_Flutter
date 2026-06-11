import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color  = AppCategories.getColor(transaction.categorie);
    final icon   = AppCategories.getIcon(transaction.categorie);
    final isInc  = transaction.isIncome;
    final amtClr = isInc ? AppColors.income : AppColors.expense;
    final sign   = isInc ? '+' : '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          transaction.categorie,
          style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description.isNotEmpty)
              Text(
                transaction.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              transaction.date,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$sign ${transaction.montant.toStringAsFixed(2)} MAD',
              style: TextStyle(
                color:      amtClr,
                fontWeight: FontWeight.bold,
                fontSize:   14,
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                onSelected: (value) {
                  if (value == 'edit'   && onEdit   != null) onEdit!();
                  if (value == 'delete' && onDelete != null) onDelete!();
                },
                itemBuilder: (_) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                        value: 'edit', child: Text('Modifier')),
                  if (onDelete != null)
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer',
                            style: TextStyle(color: AppColors.expense))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}