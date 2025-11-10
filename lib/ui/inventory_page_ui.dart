import 'package:flutter/material.dart';
import '../material_details_page.dart';
import '../ui/widgets/sidebar.dart';
import '../task_page.dart';
import '../manager_page.dart';
import '../menu_management_page.dart';
import '../sales_page.dart';
import '../expenses_page.dart';
import '../inventory_page.dart';
import '../dashboard_page.dart';

class InventoryUI extends StatelessWidget {
  final List<dynamic> materials;
  final bool isLoading;
  final int currentPage;
  final int rowsPerPage;
  final int? sortColumnIndex;
  final bool sortAscending;
  final int totalItems;
  final int lowStockCount;

  final bool isSidebarOpen;
  final String username;
  final String role;
  final String userId;
  final String apiBase;
  final VoidCallback toggleSidebar;
  final VoidCallback onHome;
  final VoidCallback onDashboard;
  final VoidCallback? onAdminDashboard;
  final VoidCallback? onManagerPage;
  final VoidCallback? onMenu;
  final VoidCallback? onSales;
  final VoidCallback? onExpenses;
  final VoidCallback onLogout;

  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  final List<dynamic> lowStockMaterials;

  final int? lowStockSortColumnIndex;
  final bool lowStockSortAscending;
  final void Function(
    int columnIndex,
    bool ascending,
    Comparable Function(Map) getField,
  )
  onLowStockSort;
  final void Function(
    int columnIndex,
    bool ascending,
    Comparable Function(Map) getField,
  )
  onSort;
  final VoidCallback onGenerateReport;
  final VoidCallback onShowAddStockDialog;
  final void Function(Map mat) onEditRestock;

  final TextEditingController searchController; // 🔹 add
  final void Function(String) onSearch; // 🔹 add

  const InventoryUI({
    required this.materials,
    required this.isLoading,
    required this.currentPage,
    required this.rowsPerPage,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.totalItems,
    required this.lowStockCount,
    required this.isSidebarOpen,
    required this.username,
    required this.role,
    required this.userId,
    required this.apiBase,
    required this.toggleSidebar,
    required this.onHome,
    required this.onDashboard,
    this.onAdminDashboard,
    this.onManagerPage,
    this.onMenu,
    this.onSales,
    this.onExpenses,
    required this.onLogout,
    required this.onSort,
    required this.onGenerateReport,
    required this.onShowAddStockDialog,
    required this.onEditRestock,
    required this.lowStockSortColumnIndex,
    required this.lowStockSortAscending,
    required this.onLowStockSort,
    required this.lowStockMaterials,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onSearch,
    required this.searchController, // 🔹 add controller
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

  @override
  Widget build(BuildContext context) {
    final totalPages = (materials.length / rowsPerPage).ceil();
    final paginatedMaterials = materials.sublist(
      currentPage * rowsPerPage,
      (currentPage * rowsPerPage + rowsPerPage) > materials.length
          ? materials.length
          : currentPage * rowsPerPage + rowsPerPage,
    );
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey[900]!, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Row(
            children: [
              Sidebar(
                isSidebarOpen: isSidebarOpen,
                toggleSidebar: toggleSidebar,
                onHome: onHome,
                onDashboard: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardPage(
                        userId: userId,
                        username: username,
                        role: role,
                      ),
                    ),
                    (route) => false,
                  );
                },

                onTaskPage: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskPage(
                        userId: userId,
                        username: username,
                        role: role,
                      ),
                    ),
                  );
                },
                onAdminDashboard: onAdminDashboard,
                onMaterials: () {
                  Navigator.push(
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
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Access Denied"),
                        content: const Text(
                          "You don’t have permission to access the Inventory. This page is only available to Managers.",
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
                },
                onMenu: () {
                  Navigator.push(
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
                activePage: 'inventory',
              ),
              Expanded(
                child: Column(
                  children: [
                    // Top bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525), // Dark gray background
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isSidebarOpen ? Icons.arrow_back_ios : Icons.menu,
                              color: Colors.orange,
                            ),
                            onPressed: toggleSidebar, // ✅ call parent
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Inventory Management",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Container(height: 3, color: Colors.orange),
                    // Summary boxes
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          _StatusBox(
                            text: "Total Items: $totalItems",
                            color: Colors.orangeAccent,
                            bgOpacity: 0.2,
                          ),
                          _StatusBox(
                            text: "Low Stock: $lowStockCount",
                            color: Colors.redAccent,
                            bgOpacity: 0.2,
                          ),
                        ],
                      ),
                    ),
                    // Table
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Main Inventory Table Container
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.50,
                                    ),
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        37,
                                        37,
                                        37,
                                      ).withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Top Row: Search + Buttons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Search
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 200,
                                                  child: TextField(
                                                    controller:
                                                        searchController,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Search...',
                                                      hintStyle:
                                                          const TextStyle(
                                                            color:
                                                                Colors.white54,
                                                          ),
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 10,
                                                          ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: Colors
                                                                      .white54,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Colors
                                                                  .orangeAccent,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    // 🔹 Trigger search when Enter is pressed
                                                    onSubmitted: (value) {
                                                      final query = value
                                                          .trim();
                                                      onSearch(
                                                        query,
                                                      ); // Call the search callback
                                                    },
                                                  ),
                                                ),

                                                const SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    final query =
                                                        searchController.text
                                                            .trim();
                                                    onSearch(query);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.orangeAccent,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.search,
                                                    color: Colors.white,
                                                  ),
                                                  label: const Text(
                                                    "Search",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Action Buttons
                                            Row(
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: onGenerateReport,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.orangeAccent,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 10,
                                                        ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.picture_as_pdf,
                                                    color: Colors.white,
                                                  ),
                                                  label: const Text(
                                                    "Generate Report",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                ElevatedButton.icon(
                                                  onPressed:
                                                      onShowAddStockDialog,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.orangeAccent,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 10,
                                                        ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                  ),
                                                  label: const Text(
                                                    "Add Stock",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        // DataTable
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minWidth: 600,
                                            ),
                                            child: DataTable(
                                              sortColumnIndex: sortColumnIndex,
                                              sortAscending: sortAscending,
                                              columns: [
                                                DataColumn(
                                                  label: const Text(
                                                    "ID",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  numeric: true,
                                                  onSort: (i, asc) => onSort(
                                                    i,
                                                    asc,
                                                    (mat) => int.parse(
                                                      mat['id'].toString(),
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: const Text(
                                                    "Name",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onSort: (i, asc) => onSort(
                                                    i,
                                                    asc,
                                                    (mat) =>
                                                        mat['name'].toString(),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: const Text(
                                                    "Quantity",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  numeric: true,
                                                  onSort: (i, asc) => onSort(
                                                    i,
                                                    asc,
                                                    (mat) =>
                                                        double.tryParse(
                                                          mat['quantity']
                                                              .toString(),
                                                        ) ??
                                                        0,
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: const Text(
                                                    "Unit",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onSort: (i, asc) => onSort(
                                                    i,
                                                    asc,
                                                    (mat) =>
                                                        mat['unit'].toString(),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: const Text(
                                                    "Restock Level",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  numeric: true,
                                                  onSort: (i, asc) => onSort(
                                                    i,
                                                    asc,
                                                    (mat) =>
                                                        double.tryParse(
                                                          mat['restock_level']
                                                              .toString(),
                                                        ) ??
                                                        0,
                                                  ),
                                                ),
                                                const DataColumn(
                                                  label: Text(
                                                    "Actions",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              rows: paginatedMaterials.map((
                                                mat,
                                              ) {
                                                final isLowStock =
                                                    double.tryParse(
                                                          mat['quantity']
                                                              .toString(),
                                                        ) !=
                                                        null &&
                                                    double.tryParse(
                                                          mat['restock_level']
                                                              .toString(),
                                                        ) !=
                                                        null &&
                                                    double.parse(
                                                          mat['quantity']
                                                              .toString(),
                                                        ) <=
                                                        double.parse(
                                                          mat['restock_level']
                                                              .toString(),
                                                        );
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text(
                                                        mat['id'].toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        isLowStock
                                                            ? "${mat['name']} (Low on Stock)"
                                                            : mat['name'],
                                                        style: TextStyle(
                                                          color: isLowStock
                                                              ? Colors.redAccent
                                                              : Colors
                                                                    .blueAccent,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        (double.tryParse(
                                                                  mat['quantity']
                                                                      .toString(),
                                                                ) ??
                                                                0)
                                                            .toStringAsFixed(2),
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        mat['unit'] ?? '',
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        mat['restock_level'] ??
                                                            '',
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (_) => MaterialDetailsPage(
                                                                    materialId:
                                                                        mat['id']
                                                                            .toString(),
                                                                    materialName:
                                                                        mat['name'],
                                                                    apiBase:
                                                                        apiBase,
                                                                    userId:
                                                                        userId,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors
                                                                  .orangeAccent
                                                                  .withOpacity(
                                                                    0.75,
                                                                  ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        14,
                                                                    vertical: 8,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      20,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              "Show Entries",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () =>
                                                                onEditRestock(
                                                                  mat,
                                                                ),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .blueAccent
                                                                      .withOpacity(
                                                                        0.75,
                                                                      ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        14,
                                                                    vertical: 8,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      20,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              "Edit Restock",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // Pagination
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: currentPage > 0
                                                    ? Colors.orangeAccent
                                                    : Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                onPressed: currentPage > 0
                                                    ? onPreviousPage
                                                    : null,
                                                icon: const Icon(
                                                  Icons.arrow_back_ios,
                                                ),
                                                color: currentPage > 0
                                                    ? Colors.white
                                                    : Colors.orangeAccent,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: Text(
                                                "${currentPage + 1} / $totalPages",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    currentPage < totalPages - 1
                                                    ? Colors.orangeAccent
                                                    : Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                onPressed:
                                                    currentPage < totalPages - 1
                                                    ? onNextPage
                                                    : null,
                                                icon: const Icon(
                                                  Icons.arrow_forward_ios,
                                                ),
                                                color:
                                                    currentPage < totalPages - 1
                                                    ? Colors.white
                                                    : Colors.orangeAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Low Stock Panel
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.30,
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          37,
                                          37,
                                          37,
                                        ).withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          "⚠️ Low Stock Ingredients ($lowStockCount)",
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        initiallyExpanded: false,
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              final lowStock =
                                                  lowStockMaterials;
                                              if (lowStock.isEmpty) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    "✅ All ingredients are sufficiently stocked!",
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                );
                                              }

                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DataTable(
                                                  sortColumnIndex:
                                                      lowStockSortColumnIndex,
                                                  sortAscending:
                                                      lowStockSortAscending,
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text(
                                                        "ID",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      numeric: true,
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        "Name",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        "Quantity",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      numeric: true,
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        "Restock Level",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      numeric: true,
                                                    ),
                                                  ],
                                                  rows: lowStock.map((mat) {
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(
                                                          Text(
                                                            mat['id']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            mat['name'],
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            (double.tryParse(
                                                                      mat['quantity']
                                                                          .toString(),
                                                                    ) ??
                                                                    0)
                                                                .toStringAsFixed(
                                                                  2,
                                                                ),
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            (double.tryParse(
                                                                      mat['restock_level']
                                                                          .toString(),
                                                                    ) ??
                                                                    0)
                                                                .toStringAsFixed(
                                                                  2,
                                                                ),
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
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
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String text;
  final Color color;
  final double bgOpacity;

  const _StatusBox({
    required this.text,
    required this.color,
    required this.bgOpacity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(bgOpacity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
