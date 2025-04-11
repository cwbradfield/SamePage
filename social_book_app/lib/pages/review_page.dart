import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Book Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the book title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Genre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the genre';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Review'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write a review';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Rating'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                    ),
                    color: Colors.amber,
                    onPressed: () {
                      _rating = index + 1;
                    },
                  );
                }),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process review data
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
