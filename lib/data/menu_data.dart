import 'package:very_good_burgers/models/customization.dart';
import 'package:very_good_burgers/models/menu_item.dart';
import 'package:very_good_burgers/models/store.dart';

/// Static menu and store data.
abstract class MenuData {
  static const List<MenuItem> burgers = [
    MenuItem(id: 'b_double_smash', name: 'Double Smash Deal', description: 'Double smashed patties, American cheese, pickles, onions, VGB sauce — 20% off combo this weekend!', price: 9.99, emoji: '🍔', calories: 720, category: 'Burgers'),
    MenuItem(id: 'b1', name: 'Classic Smash', description: 'Double smashed patties, American cheese, pickles, onions, VGB sauce', price: 8.99, emoji: '🍔', calories: 650, category: 'Burgers'),
    MenuItem(id: 'b2', name: 'Bacon Blitz', description: 'Crispy bacon, cheddar, caramelized onions, BBQ aioli', price: 10.99, emoji: '🥓', calories: 820, category: 'Burgers'),
    MenuItem(id: 'b3', name: 'Mushroom Melt', description: 'Sautéed mushrooms, Swiss cheese, garlic herb butter', price: 10.49, emoji: '🍄', calories: 710, category: 'Burgers'),
    MenuItem(id: 'b4', name: 'Spicy Jalapeño', description: 'Pepper jack, jalapeños, chipotle mayo, crispy onions', price: 9.99, emoji: '🌶️', calories: 690, category: 'Burgers'),
    MenuItem(id: 'b5', name: 'The VGB Double', description: 'Four patties, double cheese, all the fixings', price: 14.99, emoji: '🔥', calories: 1200, category: 'Burgers'),
    MenuItem(id: 'b6', name: 'Veggie Deluxe', description: 'Plant-based patty, avocado, sprouts, vegan cheese', price: 11.49, emoji: '🥬', calories: 480, category: 'Burgers'),
  ];

  static const List<MenuItem> sides = [
    MenuItem(id: 's1', name: 'Classic Fries', description: 'Hand-cut, twice-fried, perfectly salted', price: 3.99, emoji: '🍟', calories: 380, category: 'Sides'),
    MenuItem(id: 's2', name: 'Loaded Fries', description: 'Cheese, bacon bits, green onions, ranch', price: 6.99, emoji: '🧀', calories: 620, category: 'Sides'),
    MenuItem(id: 's3', name: 'Onion Rings', description: 'Beer-battered, served with spicy ketchup', price: 4.99, emoji: '🧅', calories: 450, category: 'Sides'),
    MenuItem(id: 's4', name: 'Sweet Potato Fries', description: 'Crispy with cinnamon sugar dust', price: 4.49, emoji: '🍠', calories: 340, category: 'Sides'),
    MenuItem(id: 's5', name: 'Mac & Cheese Bites', description: 'Crispy fried, gooey center', price: 5.99, emoji: '🧈', calories: 520, category: 'Sides'),
  ];

  static const List<MenuItem> drinks = [
    MenuItem(id: 'd1', name: 'Fountain Drink', description: 'Coke, Sprite, Fanta, Dr Pepper', price: 2.49, emoji: '🥤', calories: 180, category: 'Drinks'),
    MenuItem(id: 'd2', name: 'Fresh Lemonade', description: 'House-made, perfectly tart', price: 3.49, emoji: '🍋', calories: 120, category: 'Drinks'),
    MenuItem(id: 'd3', name: 'Milkshake', description: 'Vanilla, chocolate, or strawberry', price: 5.99, emoji: '🥛', calories: 580, category: 'Drinks'),
    MenuItem(id: 'd4', name: 'Iced Tea', description: 'Unsweetened or sweet', price: 2.49, emoji: '🧊', calories: 90, category: 'Drinks'),
    MenuItem(id: 'd5', name: 'Craft Root Beer', description: 'Small-batch, extra fizzy', price: 3.99, emoji: '🍺', calories: 200, category: 'Drinks'),
  ];

  static const List<MenuItem> desserts = [
    MenuItem(id: 'ds1', name: 'Chocolate Brownie', description: 'Warm, fudgy, with vanilla ice cream', price: 5.49, emoji: '🍫', calories: 480, category: 'Desserts'),
    MenuItem(id: 'ds2', name: 'Apple Pie Bites', description: 'Cinnamon sugar, caramel drizzle', price: 4.99, emoji: '🥧', calories: 360, category: 'Desserts'),
    MenuItem(id: 'ds3', name: 'Cookie Sandwich', description: 'Ice cream between fresh-baked cookies', price: 5.99, emoji: '🍪', calories: 520, category: 'Desserts'),
  ];

  static const List<MenuItem> combos = [
    MenuItem(id: 'c1', name: 'Classic Combo', description: 'Classic Smash + Fries + Drink', price: 12.99, emoji: '🎁', calories: 1200, category: 'Combos'),
    MenuItem(id: 'c2', name: 'Bacon Lover Combo', description: 'Bacon Blitz + Loaded Fries + Drink', price: 16.99, emoji: '⭐', calories: 1620, category: 'Combos'),
    MenuItem(id: 'c3', name: 'Family Feast', description: '4 Burgers + 2 Large Fries + 4 Drinks', price: 44.99, emoji: '👨‍👩‍👧‍👦', calories: 3800, category: 'Combos'),
  ];

  static List<MenuItem> get allMenuItems => [...burgers, ...sides, ...drinks, ...desserts, ...combos];

  static MenuItem? getItemById(String id) {
    try {
      return allMenuItems.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static const List<String> categoryTabs = ['Burgers', 'Sides', 'Drinks', 'Desserts', 'Combos'];

  static List<MenuItem> itemsForCategory(String category) {
    switch (category) {
      case 'Burgers':
        return burgers;
      case 'Sides':
        return sides;
      case 'Drinks':
        return drinks;
      case 'Desserts':
        return desserts;
      case 'Combos':
        return combos;
      default:
        return [];
    }
  }

  // --- Customizations by category ---

  static const List<Customization> burgerCustomizations = [
    Customization(id: 'extra_patty', name: 'Extra Patty', price: 2.50),
    Customization(id: 'extra_cheese', name: 'Extra Cheese', price: 1.00),
    Customization(id: 'add_bacon', name: 'Add Bacon', price: 1.50),
    Customization(id: 'add_avocado', name: 'Add Avocado', price: 1.50),
    Customization(id: 'no_onions', name: 'No Onions', price: 0),
    Customization(id: 'no_pickles', name: 'No Pickles', price: 0),
    Customization(id: 'gluten_free_bun', name: 'Gluten-Free Bun', price: 1.00),
    Customization(id: 'lettuce_wrap', name: 'Lettuce Wrap', price: 0),
  ];

  static const List<Customization> sidesCustomizations = [
    Customization(id: 'large', name: 'Make it Large', price: 1.50),
    Customization(id: 'extra_sauce', name: 'Extra Sauce', price: 0.50),
  ];

  static const List<Customization> drinksCustomizations = [
    Customization(id: 'large', name: 'Large Size', price: 0.75),
    Customization(id: 'extra_ice', name: 'Extra Ice', price: 0),
    Customization(id: 'no_ice', name: 'No Ice', price: 0),
  ];

  static List<Customization> customizationsForCategory(String category) {
    switch (category) {
      case 'Burgers':
        return burgerCustomizations;
      case 'Sides':
        return sidesCustomizations;
      case 'Drinks':
        return drinksCustomizations;
      case 'Desserts':
      case 'Combos':
        return [];
      default:
        return [];
    }
  }

  // --- Stores ---

  static const List<Store> stores = [
    Store(id: 'store1', name: 'VGB Downtown', address: '123 Main Street', city: 'New York, NY 10001', distance: '0.3 mi', hours: '10:00 AM - 10:00 PM'),
    Store(id: 'store2', name: 'VGB Midtown', address: '456 Oak Avenue', city: 'New York, NY 10018', distance: '1.2 mi', hours: '10:00 AM - 11:00 PM'),
    Store(id: 'store3', name: 'VGB Westside', address: '789 Palm Boulevard', city: 'New York, NY 10024', distance: '2.8 mi', hours: '11:00 AM - 9:00 PM'),
    Store(id: 'store4', name: 'VGB Brooklyn', address: '321 Atlantic Ave', city: 'Brooklyn, NY 11201', distance: '3.5 mi', hours: '10:00 AM - 10:00 PM'),
  ];

  static Store get defaultStore => stores.first;

  // --- Rewards (redeemable items) ---

  static const List<Map<String, dynamic>> redeemableRewards = [
    {'name': 'Free Classic Fries', 'points': 10, 'emoji': '🍟', 'itemId': 's1'},
    {'name': 'Free Fountain Drink', 'points': 10, 'emoji': '🥤', 'itemId': 'd1'},
    {'name': 'Free Cookie Sandwich', 'points': 10, 'emoji': '🍪', 'itemId': 'ds3'},
    {'name': 'Free Classic Smash', 'points': 10, 'emoji': '🍔', 'itemId': 'b1'},
  ];
}
