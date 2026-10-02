import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = ProductStore();
  await store.load();
  runApp(ShreeShyamApp(store: store));
}

class Product {
  final String id;
  String name;
  String brand;
  String category;
  String size;
  String design;
  String colour;
  String finish;
  double boxSqft;
  double stockBox;
  double purchasePrice;
  double ourPrice;
  double sellingPrice;
  double mrp;
  double gst;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.size,
    required this.design,
    required this.colour,
    required this.finish,
    required this.boxSqft,
    required this.stockBox,
    required this.purchasePrice,
    required this.ourPrice,
    required this.sellingPrice,
    required this.mrp,
    required this.gst,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'category': category,
        'size': size,
        'design': design,
        'colour': colour,
        'finish': finish,
        'boxSqft': boxSqft,
        'stockBox': stockBox,
        'purchasePrice': purchasePrice,
        'ourPrice': ourPrice,
        'sellingPrice': sellingPrice,
        'mrp': mrp,
        'gst': gst,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        name: j['name'] ?? '',
        brand: j['brand'] ?? '',
        category: j['category'] ?? 'Tile',
        size: j['size'] ?? '',
        design: j['design'] ?? '',
        colour: j['colour'] ?? '',
        finish: j['finish'] ?? '',
        boxSqft: (j['boxSqft'] ?? 0).toDouble(),
        stockBox: (j['stockBox'] ?? 0).toDouble(),
        purchasePrice: (j['purchasePrice'] ?? 0).toDouble(),
        ourPrice: (j['ourPrice'] ?? 0).toDouble(),
        sellingPrice: (j['sellingPrice'] ?? 0).toDouble(),
        mrp: (j['mrp'] ?? 0).toDouble(),
        gst: (j['gst'] ?? 18).toDouble(),
      );
}

class ProductStore extends ChangeNotifier {
  static const key = 'products_v1';
  final List<Product> products = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) {
      products.addAll(_demoProducts());
      await save();
    } else {
      final list = jsonDecode(raw) as List;
      products.addAll(list.map((e) => Product.fromJson(e)));
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(products.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> add(Product p) async {
    products.add(p);
    await save();
  }

  Future<void> update(Product p) async {
    final i = products.indexWhere((x) => x.id == p.id);
    if (i >= 0) products[i] = p;
    await save();
  }

  double get stockValue => products.fold(0, (sum, p) => sum + p.stockBox * p.ourPrice);
  int get lowStock => products.where((p) => p.stockBox <= 5).length;

  List<Product> _demoProducts() => [
        Product(id: '1', name: 'Kajaria White', brand: 'Kajaria', category: 'Tile', size: '2x4', design: 'White Marble', colour: 'White', finish: 'Glossy', boxSqft: 8, stockBox: 25, purchasePrice: 800, ourPrice: 850, sellingPrice: 1050, mrp: 1200, gst: 18),
        Product(id: '2', name: 'Somany Grey', brand: 'Somany', category: 'Tile', size: '4x4', design: 'Grey Stone', colour: 'Grey', finish: 'Matt', boxSqft: 16, stockBox: 40, purchasePrice: 680, ourPrice: 720, sellingPrice: 900, mrp: 1000, gst: 18),
        Product(id: '3', name: 'Vitrified Beige', brand: 'Kajaria', category: 'Vitrified', size: '2x2', design: 'Beige', colour: 'Beige', finish: 'Glossy', boxSqft: 10, stockBox: 18, purchasePrice: 640, ourPrice: 680, sellingPrice: 850, mrp: 950, gst: 18),
        Product(id: '4', name: 'Granite Black', brand: 'Shree Shyam', category: 'Granite', size: '8ft', design: 'Black Galaxy', colour: 'Black', finish: 'Polished', boxSqft: 20, stockBox: 4, purchasePrice: 1800, ourPrice: 1950, sellingPrice: 2400, mrp: 2600, gst: 18),
      ];
}

class ShreeShyamApp extends StatelessWidget {
  final ProductStore store;
  const ShreeShyamApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shree Shyam Tiles & Granite',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF064B88)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'sans',
      ),
      home: HomeShell(store: store),
    );
  }
}

class HomeShell extends StatefulWidget {
  final ProductStore store;
  const HomeShell({super.key, required this.store});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(store: widget.store, onOpenStock: () => setState(() => index = 1)),
      StockScreen(store: widget.store),
      PriceScreen(store: widget.store),
      MoreScreen(store: widget.store),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Stock'),
          NavigationDestination(icon: Icon(Icons.sell_outlined), selectedIcon: Icon(Icons.sell), label: 'Price'),
          NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  final String title;
  final bool back;
  const AppHeader({super.key, required this.title, this.back = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 14),
      decoration: const BoxDecoration(color: Color(0xFF064B88)),
      child: Row(children: [
        if (back) ...[
          IconButton(onPressed: () => Navigator.pop(context), color: Colors.white, icon: const Icon(Icons.arrow_back)),
          const SizedBox(width: 2),
        ],
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))),
        const Icon(Icons.notifications_none, color: Colors.white),
      ]),
    );
  }
}

class Dashboard extends StatelessWidget {
  final ProductStore store;
  final VoidCallback onOpenStock;
  const Dashboard({super.key, required this.store, required this.onOpenStock});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (_, __) => SafeArea(
        top: false,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: AppHeader(title: 'Shree Shyam Tiles & Granite')),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Row(children: [
                  CircleAvatar(radius: 24, backgroundColor: Color(0xFFEAF2FB), child: Icon(Icons.store, color: Color(0xFF064B88))),
                  SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome to Shree Shyam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 3), Text('Tiles & Granite • Inventory', style: TextStyle(color: Colors.grey)),
                  ])),
                ]),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(title: 'Total Stock', value: '${store.products.fold<double>(0, (s,p) => s+p.stockBox).toStringAsFixed(0)} Box', icon: Icons.inventory_2, color: Colors.green),
                  StatCard(title: 'Stock Value', value: money(store.stockValue), icon: Icons.account_balance_wallet, color: Colors.deepPurple),
                  StatCard(title: 'Products', value: '${store.products.length}', icon: Icons.grid_view, color: Colors.orange),
                  StatCard(title: 'Low Stock', value: '${store.lowStock}', icon: Icons.warning_amber, color: Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Top Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: onOpenStock, child: const Text('View All')),
              ]),
              ...store.products.take(3).map((p) => ProductTile(product: p)),
            ])),
          ),
        ]),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color), const Spacer(), Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    ]),
  );
}

class StockScreen extends StatefulWidget {
  final ProductStore store;
  const StockScreen({super.key, required this.store});
  @override State<StockScreen> createState() => _StockScreenState();
}
class _StockScreenState extends State<StockScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (_, __) {
        final list = widget.store.products.where((p) => '${p.name} ${p.brand} ${p.category} ${p.size}'.toLowerCase().contains(query.toLowerCase())).toList();
        return SafeArea(top: false, child: Column(children: [
          const AppHeader(title: 'Tile & Granite Stock'),
          Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search product, brand, size...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
          )),
          Expanded(child: list.isEmpty ? const Center(child: Text('No products found')) : ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: list.length,
            itemBuilder: (_, i) => ProductTile(product: list[i], onTap: () => showProduct(context, list[i], widget.store)),
          )),
          Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductScreen(store: widget.store))),
            icon: const Icon(Icons.add), label: const Text('Add Product'),
          )))
        ]));
      },
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductTile({super.key, required this.product, this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(10)), child: Icon(product.category == 'Granite' ? Icons.texture : Icons.grid_on, color: const Color(0xFF064B88))),
      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${product.brand} • ${product.size}\nStock: ${product.stockBox.toStringAsFixed(0)} Box'),
      isThreeLine: true,
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('Our Price', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text(money(product.ourPrice), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)), Text('Sell ${money(product.sellingPrice)}', style: const TextStyle(fontSize: 11))]),
    ),
  );
}

class PriceScreen extends StatefulWidget {
  final ProductStore store;
  const PriceScreen({super.key, required this.store});
  @override State<PriceScreen> createState() => _PriceScreenState();
}
class _PriceScreenState extends State<PriceScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: widget.store, builder: (_, __) {
    final list = widget.store.products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    return SafeArea(top: false, child: Column(children: [
      const AppHeader(title: 'Our Price List'),
      Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: (v) => setState(() => query = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search tile / granite...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: list.length, itemBuilder: (_, i) {
        final p = list[i];
        return Card(color: Colors.white, elevation: 0, child: ListTile(title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${p.size} • ${p.finish} • Stock ${p.stockBox.toStringAsFixed(0)} Box'), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(money(p.ourPrice), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), Text('Sell ${money(p.sellingPrice)}', style: const TextStyle(fontSize: 11))])));
      }))
    ]));
  });
}

class AddProductScreen extends StatefulWidget {
  final ProductStore store;
  const AddProductScreen({super.key, required this.store});
  @override State<AddProductScreen> createState() => _AddProductScreenState();
}
class _AddProductScreenState extends State<AddProductScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), brand = TextEditingController(), size = TextEditingController(), design = TextEditingController(), colour = TextEditingController(), finish = TextEditingController(), sqft = TextEditingController(), stock = TextEditingController(), purchase = TextEditingController(), our = TextEditingController(), selling = TextEditingController(), mrp = TextEditingController();
  String category = 'Tile';

  @override void dispose() { for (final c in [name,brand,size,design,colour,finish,sqft,stock,purchase,our,selling,mrp]) { c.dispose(); } super.dispose(); }
  String? req(String? v) => v == null || v.trim().isEmpty ? 'Required' : null;
  double num(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  Future<void> saveProduct() async {
    if (!form.currentState!.validate()) return;
    final p = Product(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), brand: brand.text.trim(), category: category, size: size.text.trim(), design: design.text.trim(), colour: colour.text.trim(), finish: finish.text.trim(), boxSqft: num(sqft), stockBox: num(stock), purchasePrice: num(purchase), ourPrice: num(our), sellingPrice: num(selling), mrp: num(mrp), gst: 18);
    await widget.store.add(p);
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product saved successfully'))); Navigator.pop(context); }
  }

  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Add Product')), body: Form(key: form, child: ListView(padding: const EdgeInsets.all(16), children: [
    field(name, 'Product Name', validator: req), field(brand, 'Brand', validator: req),
    DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()), items: const ['Tile','Vitrified','Granite','Marble'].map((x) => DropdownMenuItem(value:x, child:Text(x))).toList(), onChanged: (v) => setState(() => category = v!)),
    const SizedBox(height: 12), field(size, 'Size (e.g. 2x4)'), field(design, 'Design / Model'), field(colour, 'Colour'), field(finish, 'Finish'),
    Row(children: [Expanded(child: field(sqft, 'Box Sq.ft', keyboard: TextInputType.number)), const SizedBox(width: 10), Expanded(child: field(stock, 'Stock Box', keyboard: TextInputType.number))]),
    Row(children: [Expanded(child: field(purchase, 'Purchase Price', keyboard: TextInputType.number)), const SizedBox(width: 10), Expanded(child: field(our, 'Our Price', keyboard: TextInputType.number))]),
    Row(children: [Expanded(child: field(selling, 'Selling Price', keyboard: TextInputType.number)), const SizedBox(width: 10), Expanded(child: field(mrp, 'MRP', keyboard: TextInputType.number))]),
    const SizedBox(height: 10), SizedBox(height: 52, child: FilledButton.icon(onPressed: saveProduct, icon: const Icon(Icons.save), label: const Text('Save Product'))),
  ])));

  Widget field(TextEditingController c, String label, {String? Function(String?)? validator, TextInputType? keyboard}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, validator: validator, keyboardType: keyboard, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white, border: const OutlineInputBorder())));
}

class MoreScreen extends StatelessWidget {
  final ProductStore store;
  const MoreScreen({super.key, required this.store});
  @override Widget build(BuildContext context) => SafeArea(top:false, child: Column(children: [
    const AppHeader(title: 'More'),
    Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
      moreTile(context, Icons.shopping_cart, 'Purchase', 'Purchase entry and stock increase', () => placeholder(context, 'Purchase module is next')),
      moreTile(context, Icons.receipt_long, 'Sales & Bill', 'Sale, GST and invoice', () => placeholder(context, 'Sales & Bill module is next')),
      moreTile(context, Icons.people, 'Customers', 'Customer and due management', () => placeholder(context, 'Customer module is next')),
      moreTile(context, Icons.factory, 'Suppliers', 'Supplier and purchase history', () => placeholder(context, 'Supplier module is next')),
      moreTile(context, Icons.bar_chart, 'Reports', 'Sales, purchase, profit and stock', () => placeholder(context, 'Reports module is next')),
      moreTile(context, Icons.settings, 'Settings', 'Shop details and backup', () => placeholder(context, 'Settings module is next')),
    ]))
  ]));
  Widget moreTile(BuildContext c, IconData icon, String title, String sub, VoidCallback tap) => Card(color:Colors.white, elevation:0, child: ListTile(onTap:tap, leading:CircleAvatar(backgroundColor:const Color(0xFFEAF2FB), child:Icon(icon,color:const Color(0xFF064B88))), title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)), subtitle:Text(sub), trailing:const Icon(Icons.chevron_right)));
}

void showProduct(BuildContext context, Product p, ProductStore store) {
  showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 30), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    Text('${p.brand} • ${p.category} • ${p.size}'), const SizedBox(height: 16),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [labelValue('Stock', '${p.stockBox.toStringAsFixed(0)} Box'), labelValue('Our Price', money(p.ourPrice)), labelValue('Selling', money(p.sellingPrice))]),
    const SizedBox(height: 12), Text('Purchase: ${money(p.purchasePrice)}   •   MRP: ${money(p.mrp)}'),
  ]));
}
Widget labelValue(String l, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]);
void placeholder(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
String money(double v) => '₹${v.toStringAsFixed(0)}';
