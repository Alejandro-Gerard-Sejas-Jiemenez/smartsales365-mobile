import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Function()? onTap;
  final Function()? onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  }) : super(key: key);

  TextStyle _priceStyle(BuildContext context) => TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  TextStyle _titleStyle(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    height: 1.2, // Reduce el espaciado entre líneas
  );

  TextStyle _statusStyle(bool inStock) => TextStyle(
    color: inStock ? AppColors.success : AppColors.error,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

@override
Widget build(BuildContext context) {
  return Container(
    width: 160,
    height: 350, // Aumentada altura para eliminar el overflow
    child: Card(
      elevation: 2,
      margin: EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // Imagen del producto
            SizedBox(
              height: 150, // Altura ajustada para mejor proporción
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: product.imagenUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8), // Reducido de 12 a 8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto
                    Text(
                      product.nombre,
                      style: _titleStyle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4), // Reducido de 8 a 4
                    
                    // Precio
                    Text(
                      'Bs. ${product.precioVenta.toStringAsFixed(2)}',
                      style: _priceStyle(context),
                    ),
                    
                    SizedBox(height: 4), // Reducido de 8 a 4
                    
                    // Stock
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stockActual > 0 
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.stockActual > 0 ? 'En stock' : 'Sin stock',
                        style: _statusStyle(product.stockActual > 0),
                      ),
                    ),
                    
                    Spacer(), // Empuja el botón hacia abajo
                    
                    // Botón de agregar al carrito
                    Container(
                      width: double.infinity,
                      height: 25, // Altura fija más pequeña
                      child: ElevatedButton(
                        onPressed: product.stockActual > 0 ? onAddToCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero, // Sin padding
                          minimumSize: Size.zero, // Sin tamaño mínimo
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce el área de toque
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Agregar al carrito',
                          style: TextStyle(fontSize: 13), // Texto más pequeño
                        ),
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
  );
 }
}
