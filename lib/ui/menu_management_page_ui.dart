import 'package:flutter/material.dart';
import 'widgets/sidebar.dart';
import '../manager_page.dart';
import '../menu_management_page.dart';
import '../inventory_page.dart';
import '../sales_page.dart';
import '../expenses_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuManagementPageUI extends StatelessWidget {
  final bool isSidebarOpen;
  final VoidCallback toggleSidebar;
  final List menuItems;
  final bool isLoading;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool showHidden;
  final VoidCallback onShowHiddenToggle;
  final VoidCallback onAddEntry;
  final Function(Map) onEditMenu;
  final Function(int, String) onToggleMenu;
  final void Function(Comparable Function(Map), int, bool) onSort;
  final String username;
  final String role;
  final String userId;
  final VoidCallback onHome;
  final VoidCallback onDashboard;
  final VoidCallback onTaskPage;
  final Future<void> Function() onLogout;

  final Function(int) onViewIngredients;

  final int? selectedMenuId;
  final List<Map> selectedMenuIngredients;
  final Function(int) onAddIngredient;
  final Function(int, int) onDeleteIngredient;

  const MenuManagementPageUI({
    required this.isSidebarOpen,
    required this.toggleSidebar,
    required this.menuItems,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.showHidden,
    required this.onShowHiddenToggle,
    required this.onAddEntry,
    required this.onEditMenu,
    required this.onToggleMenu,
    required this.onSort,
    required this.username,
    required this.role,
    required this.userId,
    required this.onHome,
    required this.onDashboard,
    required this.onTaskPage,
    required this.onLogout,
    required this.onViewIngredients,
    required this.selectedMenuId,
    required this.selectedMenuIngredients,
    required this.onAddIngredient,
    required this.onDeleteIngredient,
    Key? key,
  }) : super(key: key);

  void _showAccessDeniedDialog(BuildContext context, String pageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Access Denied"),
        content: Text(
          "You don’t have permission to access $pageName. This page is only available to Managers.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

void _showIngredientsPopup(BuildContext context, List<Map> ingredients) {
  if (ingredients.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Ingredients for Selected Menu",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: const Text(
          "No ingredients added yet.",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Ingredients for Selected Menu",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            dataTextStyle: const TextStyle(color: Colors.black87),
            columns: const [
              DataColumn(label: Text("Raw Material")),
              DataColumn(label: Text("Quantity")),
              DataColumn(label: Text("Unit")),
              DataColumn(label: Text("Actions")),
            ],
            rows: ingredients.map((ingredient) {
              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                  (states) => ingredients.indexOf(ingredient).isEven
                      ? Colors.white
                      : Colors.grey[50],
                ),
                cells: [
                  DataCell(Text(ingredient['name'] ?? "")),
                  DataCell(Text(ingredient['quantity']?.toString() ?? "")),
                  DataCell(Text(ingredient['unit']?.toString() ?? "")),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (selectedMenuId != null) {
                          onDeleteIngredient(
                            selectedMenuId!,
                            int.parse(ingredient['id'].toString()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final filteredMenuItems = menuItems.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? 'visible';
      return showHidden ? status == 'hidden' : status == 'visible';
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          // === BACKGROUND GRADIENT ===
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF6F7FB),
                  Colors.white.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Row(
            children: [
              Sidebar(
                isSidebarOpen: isSidebarOpen,
                onHome: onHome,
                onDashboard: onDashboard,
                onTaskPage: onTaskPage,
                onMaterials: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManagerPage(
                        username: username,
                        role: role,
                        userId: userId,
                      ),
                    ),
                  );
                },
                onInventory: () {
                  if (role.toLowerCase() == "manager") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InventoryManagementPage(
                          userId: userId,
                          username: username,
                          role: role,
                          isSidebarOpen: isSidebarOpen,
                          toggleSidebar: toggleSidebar,
                          onHome: onHome,
                          onDashboard: onDashboard,
                          onLogout: onLogout,
                        ),
                      ),
                    );
                  } else {
                    _showAccessDeniedDialog(context, "Inventory");
                  }
                },
                onMenu: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MenuManagementPage(
                        username: username,
                        role: role,
                        userId: userId,
                      ),
                    ),
                  );
                },
                onSales: () {
                  if (role.toLowerCase() == "manager") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SalesContent(
                          userId: userId,
                          username: username,
                          role: role,
                          isSidebarOpen: isSidebarOpen,
                          toggleSidebar: toggleSidebar,
                          onHome: () => onHome,
                          onDashboard: () => onDashboard,
                          onLogout: onLogout,
                        ),
                      ),
                    );
                  } else {
                    _showAccessDeniedDialog(context, "Sales");
                  }
                },
                onExpenses: () {
                  if (role.toLowerCase() == "manager") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpensesContent(
                          userId: userId,
                          username: username,
                          role: role,
                          isSidebarOpen: isSidebarOpen,
                          toggleSidebar: toggleSidebar,
                          onHome: () => onHome,
                          onDashboard: () => onDashboard,
                          onLogout: onLogout,
                        ),
                      ),
                    );
                  } else {
                    _showAccessDeniedDialog(context, "Expenses");
                  }
                },
                username: username,
                role: role,
                userId: userId,
                onLogout: onLogout,
                activePage: "menu",
              ),

              // -------------------- MAIN CONTENT --------------------
              Expanded(
                child: Column(
                  children: [
                    // === TOP BAR ===
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isSidebarOpen
                                    ? Icons.arrow_back_ios
                                    : Icons.menu,
                                color: Colors.orange,
                              ),
                              onPressed: toggleSidebar,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Manager - Menu Management",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: onShowHiddenToggle,
                              icon: Icon(
                                showHidden
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              label: Text(
                                showHidden
                                    ? "Visible Menu"
                                    : "Hidden Menu",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: showHidden
                                    ? Colors.green
                                    : Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: onAddEntry,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                "Add Menu",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // === MAIN CONTENT ===
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.95,
                                        ),
                                        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: LayoutBuilder(
  builder: (context, constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        // expands the table to fill available width, but scrolls if smaller
        constraints: BoxConstraints(minWidth: constraints.maxWidth),
        child: DataTable(
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          headingRowColor:
              MaterialStateProperty.all(Colors.orange.shade100),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          dataTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
          ),
          dividerThickness: 1,
          horizontalMargin: 24,
          columnSpacing: 40,
          border: TableBorder(
            horizontalInside: BorderSide(
              width: 0.5,
              color: Colors.grey.shade300,
            ),
          ),
          columns: [
            const DataColumn(label: Text("Image")),
            DataColumn(
              label: const Text("Product Name"),
              onSort: (col, asc) => onSort(
                (m) => m['name'] ?? '',
                col,
                asc,
              ),
            ),
            DataColumn(
              label: const Text("Price"),
              onSort: (col, asc) => onSort(
                (m) => double.tryParse(
                        m['price']?.toString() ?? "0") ??
                    0,
                col,
                asc,
              ),
            ),
            const DataColumn(label: Text("Description")),
            const DataColumn(label: Text("Category")),
            const DataColumn(label: Text("Actions")),
          ],
          rows: filteredMenuItems.map<DataRow>((item) {
            final id = int.parse(item['id'].toString());
            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                (states) => filteredMenuItems.indexOf(item).isEven
                    ? Colors.grey[50]
                    : Colors.white,
              ),
              cells: [
                DataCell(
                  item['image'] != null &&
                          item['image'].toString().isNotEmpty
                      ? Image.network(item['image'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                ),
                DataCell(
  Text(item['name'] ?? 'Unnamed'),
  onTap: () async {
    // Make sure ingredients are updated first
    await onViewIngredients(id);
    // Then show popup with latest ingredients
    _showIngredientsPopup(context, selectedMenuIngredients);
  },
),

                DataCell(Text("₱${item['price']}")),
                DataCell(SizedBox(
                  width: 200,
                  child: Text(
                    item['description'] ?? "No description",
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                DataCell(Text(item['category'] ?? "")),
                DataCell(Row(
                  children: [
                    // Edit
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue, size: 24),
                        tooltip: "Edit Menu",
                        onPressed: () => onEditMenu(item),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Show / Hide
                    Container(
                      decoration: BoxDecoration(
                        color: (item['status'] == "visible"
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          item['status'] == "visible"
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: item['status'] == "visible"
                              ? Colors.green
                              : Colors.red,
                          size: 24,
                        ),
                        tooltip: item['status'] == "visible"
                            ? "Hide Menu"
                            : "Show Menu",
                        onPressed: () => onToggleMenu(
                          int.parse(item['id'].toString()),
                          item['status'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Add Ingredient
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.playlist_add,
                            color: Colors.orange, size: 24),
                        tooltip: "Add Ingredient",
                        onPressed: () {
                          onViewIngredients(id);
                          if (selectedMenuIngredients.isNotEmpty) {
_showIngredientsPopup(context, selectedMenuIngredients);
                          }
                        },
                      ),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  },
),

                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
