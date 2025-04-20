import 'package:flutter/material.dart';

class CustomErrorWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;
  const CustomErrorWidget({super.key, required this.message,required this.onRetry});

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.white,
       body: SafeArea(
         child: Center(
           child: Padding(
             padding: const EdgeInsets.all(24),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(
                   Icons.error_outline,
                   size: 64,
                   color: Colors.red,
                 ),
                 const SizedBox(height: 16),
                 Text(
                   'An Error Occured',
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   widget.message,
                   textAlign: TextAlign.center,
                   style: Theme.of(context).textTheme.bodyMedium,
                 ),
                 const SizedBox(height: 24),
                 ElevatedButton(
                   onPressed: widget.onRetry,
                   child: const Text('Try Again'),
                 ),
               ],
             ),
           ),
         ),
       ),
     );
   }
}