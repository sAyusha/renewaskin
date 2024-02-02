import 'package:csv/csv.dart' as csv;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SkinProductPage extends StatefulWidget {
  final String predictedSkinType;
  final List<String> selectedSkinConcerns;
  const SkinProductPage({
    Key? key,
    required this.predictedSkinType,
    required this.selectedSkinConcerns,
  }) : super(key: key);

  @override
  SkinProductPageState createState() => SkinProductPageState();
}

class SkinProductPageState extends State<SkinProductPage> {
  late Future<List<SkinProduct>> productsFuture;
  late String priceValue = '';
  List<String> selectedSkinConcerns = [];

  @override
  void initState() {
    super.initState();
    // store the selected skin concerns
    selectedSkinConcerns = widget.selectedSkinConcerns;
    // Load product recommendations based on the determined skin type
    productsFuture = loadProducts();
  }

  Future<List<SkinProduct>> loadProducts() async {
    try {
      // Load the CSV data and filter products based on skin type
      String csvData = await rootBundle.loadString('assets/final.csv');
      List<List<dynamic>> csvList =
          const csv.CsvToListConverter().convert(csvData);

      // Debug prints
      print('Predicted Skin Type: ${widget.predictedSkinType}');

      // Count the rows that match the predicted skin type
      int rowCount = countRowsBySkinTypeAndConcerns(csvList, widget.predictedSkinType, widget.selectedSkinConcerns);
      // print('Number of rows with predicted skin type: $rowCount');

      // Print values of index 4 column for matching rows
      print('Values of index 4 column for matching rows:');

      printBrand(csvList, widget.predictedSkinType, columnIndex: 4);
      printLabel(csvList, widget.predictedSkinType, columnIndex: 2);
      printName(csvList, widget.predictedSkinType, columnIndex: 5);
      printPrice(csvList, widget.predictedSkinType, columnIndex: 6);
      printImg(csvList, widget.predictedSkinType, columnIndex: 8);

      // Filter products based on the predicted skin type
      List<SkinProduct> filteredProducts = filterProductsBySkinTypeAndConcerns(
          csvList, widget.predictedSkinType, widget.selectedSkinConcerns);

      return filteredProducts;
    } catch (e) {
      print('Error loading CSV file: $e');
      return [];
    }
  }

  int countRowsBySkinTypeAndConcerns(
      List<List<dynamic>> csvList, String skintype, List<String> skinConcerns) {
    int count = 0;
    for (var row in csvList) {
      if (row.isNotEmpty && row.length > 6) {
        String rowSkinType = row[7].toString().toLowerCase().trim();
        if (rowSkinType == skintype.toLowerCase().trim() &&
            matchesConcerns(row, skinConcerns)) {
          count++;
        }
      }
    }
    return count;
  }

  void printBrand(List<List<dynamic>> csvList, String skintype,
      {required int columnIndex}) {
    for (var row in csvList) {
      if (row.isNotEmpty && row.length > 6) {
        String rowSkinType = row[7].toString().toLowerCase().trim();
        if (rowSkinType == skintype.toLowerCase().trim()) {
          // Assuming columnIndex is 4, adjust it if needed
          String columnValue =
              row.length > columnIndex ? row[columnIndex].toString() : '';
          print('Brand: $columnValue');
        }
      }
    }
  }

  void printLabel(List<List<dynamic>> csvList, String skintype,
      {required int columnIndex}) {
    for (var row in csvList) {
      if (row.isNotEmpty && row.length > 6) {
        String rowSkinType = row[7].toString().toLowerCase().trim();
        if (rowSkinType == skintype.toLowerCase().trim()) {
          // Assuming columnIndex is 4, adjust it if needed
          String columnValue =
              row.length > columnIndex ? row[columnIndex].toString() : '';
          print('Label: $columnValue');
        }
      }
    }
  }

  void printName(List<List<dynamic>> csvList, String skintype,
      {required int columnIndex}) {
    for (var row in csvList) {
      if (row.isNotEmpty && row.length > 6) {
        String rowSkinType = row[7].toString().toLowerCase().trim();
        if (rowSkinType == skintype.toLowerCase().trim()) {
          // Assuming columnIndex is 4, adjust it if needed
          String columnValue =
              row.length > columnIndex ? row[columnIndex].toString() : '';
          print('Name: $columnValue');
        }
      }
    }
  }

 bool matchesConcerns(List<dynamic> row, List<String> skinConcerns) {
  // Check if row has at least 10 elements before accessing index 9
  if (row.isNotEmpty && row.length > 8) {
    for (var concern in skinConcerns) {
      if (row[7].toString().toLowerCase().trim().contains(concern.toLowerCase().trim())) {
        return false;
      }
    }
    return true;
  } else {
    // Handle the case where the row doesn't have enough elements
    return false;
  }
}


  // void printPrice(List<List<dynamic>> csvList, String skintype,
  //     {required int columnIndex}) {
  //   for (var row in csvList) {
  //     if (row.isNotEmpty && row.length > 6) {
  //       String rowSkinType = row[7].toString().toLowerCase().trim();
  //       if (rowSkinType == skintype.toLowerCase().trim()) {
  //         // Assuming columnIndex is 4, adjust it if needed
  //         String columnValue =
  //             row.length > columnIndex ? row[columnIndex].toString() : '';
  //         print('Price: $columnValue');
  //       }
  //     }
  //   }
  // }

  String printPrice(List<List<dynamic>> csvList, String skintype,
      {required int columnIndex}) {
    for (var row in csvList) {
      if (row.isNotEmpty && row.length > 6) {
        String rowSkinType = row[6].toString().toLowerCase().trim();
        if (rowSkinType == skintype.toLowerCase().trim()) {
          // Assuming columnIndex is 5 (index 5 for the price), adjust it if needed
          String columnValue =
              row.length > columnIndex ? row[columnIndex].toString() : '';
          return columnValue;
        }
      }
    }
    return '';
  }

  void printImg(List<List<dynamic>> csvList, String skintype,
      {required int columnIndex}) {
    for (var row in csvList) {
      if (row.isNotEmpty && row.length > 6) {
        String rowSkinType = row[7].toString().toLowerCase().trim();
        if (rowSkinType == skintype.toLowerCase().trim()) {
          // Assuming columnIndex is 4, adjust it if needed
          String columnValue =
              row.length > columnIndex ? row[columnIndex].toString() : '';
          print('ImgUrl: $columnValue');
        }
      }
    }
  }

  List<SkinProduct> filterProductsBySkinTypeAndConcerns(
    List<List<dynamic>> csvList,
    String skintype,
    List<String> skinConcerns,
  ) {
    List<SkinProduct> filteredProducts = [];

    for (var row in csvList) {
      if (row.isNotEmpty &&
          row.length > 6 &&
          row[6].toString().toLowerCase().trim() ==
              skintype.toLowerCase().trim()) {
        bool matchesAllConcerns = true;
        for (var concern in skinConcerns) {
          if (row.isNotEmpty && row.length > 7 && row[7]
              .toString()
              .toLowerCase()
              .trim()
              .contains(concern.toLowerCase().trim())) {
            matchesAllConcerns = false;
            break;
          }
        }

        if (matchesAllConcerns) {
          String label = row.length > 1 ? row[1] : '';
          String price = row.length > 5 ? row[5] : '';
          String brand = row.length > 3 ? row[3] : '';
          String imageUrl = row.length > 8 ? row[8] : '';

          filteredProducts.add(
            SkinProduct(
              label: label,
              price: price,
              brand: brand,
              imageUrl: imageUrl,
            ),
          );
        }
      }
    }

    // Debug prints
    print('Predicted Skin Type: ${widget.predictedSkinType}');
    print('Skin Type: $skintype');
    print('Filtered Products: $filteredProducts');
    // print('CSV Data: $csvList');

    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 242, 186),
      appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 255, 242, 186),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // title: Text(
        //   'Recommendated Products for - ${widget.predictedSkinType} skin',
        //   style: const TextStyle(
        //     color: Colors.black,
        //     fontSize: 18,
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<SkinProduct>>(
          future: productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show loading indicator
            } else if (snapshot.hasError) {
              print('Error loading products: ${snapshot.error}');
              return const Text('Error loading products'); // Show error message
            } else if (snapshot.hasData) {
              List<SkinProduct> products = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (products.isNotEmpty)
                    SkinProductSection(
                      title: 'Recommended Skincare Products for ${widget.predictedSkinType} skin',
                      products: products,
                      priceValue: priceValue,
                    )
                  else
                    Text(
                        'No products found for ${widget.predictedSkinType} skin type.'),
                ],
              );
            } else {
              return const Text('Unknown error'); // Handle other cases
            }
          },
        ),
      ),
    );
  }
}

class SkinProductSection extends StatelessWidget {
  final String title;
  final List<SkinProduct> products;
  final String priceValue;

  const SkinProductSection({
    Key? key,
    required this.title,
    required this.products,
    required this.priceValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (products.length / 2).ceil(),
          itemBuilder: (context, index) {
            final startIndex = index * 2;
            final endIndex = startIndex + 1;
            return Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width - 40.0) / 2,
                    child: SkinProductCard(
                      product: products[startIndex],
                      priceValue: priceValue,
                    ),
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width - 40.0) / 2,
                    child: endIndex < products.length
                        ? SkinProductCard(
                            product: products[endIndex],
                            priceValue: priceValue,
                          )
                        : Container(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class SkinProductCard extends StatelessWidget {
  final SkinProduct product;
  final String priceValue;

  const SkinProductCard(
      {Key? key, required this.product, required this.priceValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.only(top: 10, bottom: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl,
              height: 150.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5.0),
                Text(
                  product.price,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5.0),
                Text(
                  product.brand,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    
    );
  }
}

class SkinProduct {
  final String label;
  final String price;
  final String brand;
  final String imageUrl;

  SkinProduct({
    required this.label,
    required this.price,
    required this.brand,
    required this.imageUrl,
  });
}
