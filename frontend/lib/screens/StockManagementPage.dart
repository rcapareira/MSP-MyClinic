import 'package:flutter/material.dart';

class StockManagementPage extends StatefulWidget {
  @override
  _StockManagementPageState createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  List<Map<String, dynamic>> _stockList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Stock Management')),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createNewItem(context),
            tooltip: 'Add New Item',
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _createPurchaseList,
            tooltip: 'Create Purchase List',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _stockList.isNotEmpty
          ? ListView.builder(
        itemCount: _stockList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildText('Item', _stockList[index]['item']),
                  _buildText('Expiry Date', _stockList[index]['expiryDate']),
                  _buildText('Current Stock', _stockList[index]['currentStock'].toString()),
                  _buildText('Minimum Stock', _stockList[index]['minStock'].toString()),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editItem(context, index),
              ),
            ),
          );
        },
      )
          : Center(child: Text('No stock items found')),
    );
  }

  Widget _buildText(String label, String value) {
    return Text('$label: $value');
  }

  void _loadStockData() {
    setState(() {
      _isLoading = true;
    });

    // Here you would typically fetch data from a backend or database
    List<Map<String, dynamic>> stockData = [
      {'item': 'Item 1', 'expiryDate': '2023-12-31', 'currentStock': 8, 'minStock': 5},
      {'item': 'Item 2', 'expiryDate': '2024-01-15', 'currentStock': 2, 'minStock': 3},
      // Add more items as needed
    ];

    setState(() {
      _stockList = stockData;
      _isLoading = false;
    });
  }

  void _createPurchaseList() {
    List<Map<String, dynamic>> purchaseList = _stockList
        .where((item) => item['currentStock'] <= item['minStock'] && item['minStock'] > 0)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase List'),
          content: purchaseList.isNotEmpty
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: purchaseList.map((item) {
              return ListTile(
                title: Text(item['item']),
                subtitle: Text('Current Stock: ${item['currentStock']} - Min Stock: ${item['minStock']}'),
              );
            }).toList(),
          )
              : Text('No items need to be purchased'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendPurchaseOrder();
              },
              child: Text('Send Purchase Order'),
            ),
          ],
        );
      },
    );
  }

  void _editItem(BuildContext context, int index) {
    TextEditingController itemController = TextEditingController(text: _stockList[index]['item']);
    TextEditingController expiryDateController = TextEditingController(text: _stockList[index]['expiryDate']);
    TextEditingController currentStockController = TextEditingController(text: _stockList[index]['currentStock'].toString());
    TextEditingController minStockController = TextEditingController(text: _stockList[index]['minStock'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: itemController,
                  decoration: InputDecoration(labelText: 'Item'),
                ),
                TextField(
                  controller: expiryDateController,
                  decoration: InputDecoration(labelText: 'Expiry Date'),
                ),
                TextField(
                  controller: currentStockController,
                  decoration: InputDecoration(labelText: 'Current Stock'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minStockController,
                  decoration: InputDecoration(labelText: 'Minimum Stock'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _stockList[index]['item'] = itemController.text;
                  _stockList[index]['expiryDate'] = expiryDateController.text;
                  _stockList[index]['currentStock'] = int.parse(currentStockController.text);
                  _stockList[index]['minStock'] = int.parse(minStockController.text);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item updated successfully!')),
                );
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _createNewItem(BuildContext context) {
    TextEditingController itemController = TextEditingController();
    TextEditingController expiryDateController = TextEditingController();
    TextEditingController currentStockController = TextEditingController();
    TextEditingController minStockController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: itemController,
                  decoration: InputDecoration(labelText: 'Item'),
                ),
                TextField(
                  controller: expiryDateController,
                  decoration: InputDecoration(labelText: 'Expiry Date'),
                ),
                TextField(
                  controller: currentStockController,
                  decoration: InputDecoration(labelText: 'Current Stock'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minStockController,
                  decoration: InputDecoration(labelText: 'Minimum Stock'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _stockList.add({
                    'item': itemController.text,
                    'expiryDate': expiryDateController.text,
                    'currentStock': int.tryParse(currentStockController.text) ?? 0,
                    'minStock': int.tryParse(minStockController.text) ?? 0,
                  });
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item added successfully!')),
                );
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _sendPurchaseOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase order sent successfully!')),
    );
  }
}
