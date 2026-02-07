import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;
import '../models/event.dart';
import '../models/transaction.dart';
import '../models/preset_item.dart';
import 'supabase_config.dart';

class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();

  DataService._();

  SupabaseClient get _client => SupabaseConfig.client;
  app_user.User? _currentUser;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ==================== Authentication ====================

  Future<app_user.User?> login(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      
      final data = await _client
          .from('users')
          .select()
          .eq('username', username.toLowerCase())
          .eq('password', hashedPassword)
          .maybeSingle();

      if (data != null) {
        _currentUser = app_user.User(
          id: data['id'],
          username: data['username'],
          password: '',
          name: data['name'],
        );
        
        // Save session locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', _currentUser!.id);
        
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<app_user.User?> signUp(String username, String password, String name) async {
    try {
      final hashedPassword = _hashPassword(password);
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Check if username exists
      final existing = await _client
          .from('users')
          .select('id')
          .eq('username', username.toLowerCase())
          .maybeSingle();
          
      if (existing != null) {
        print('Username already exists');
        return null;
      }

      await _client.from('users').insert({
        'id': userId,
        'username': username.toLowerCase(),
        'password': hashedPassword,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      });

      return app_user.User(
        id: userId,
        username: username.toLowerCase(),
        password: '',
        name: name,
      );
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  Future<app_user.User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    
    if (userId != null) {
      try {
        final data = await _client
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();
            
        if (data != null) {
          _currentUser = app_user.User(
            id: data['id'],
            username: data['username'],
            password: '',
            name: data['name'],
          );
          return _currentUser;
        }
      } catch (e) {
        print('Get current user error: $e');
      }
    }
    return null;
  }

  String? get _currentUserId => _currentUser?.id;

  // ==================== Events ====================

  Future<List<Event>> getEvents() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return await _getLocalEvents();

      final data = await _client
          .from('events')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => _eventFromSupabase(e)).toList();
    } catch (e) {
      print('Get events error: $e');
      // Fallback to local storage
      return await _getLocalEvents();
    }
  }

  Future<void> saveEvent(Event event) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        await _saveLocalEvent(event);
        return;
      }

      await _client.from('events').insert({
        'id': event.id,
        'user_id': userId,
        'name': event.name,
        'description': event.description,
        'created_at': event.createdAt.toIso8601String(),
        'created_by': event.createdBy,
        'is_active': event.isActive,
        'preset_items': event.presetItems.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      print('Save event error: $e');
      await _saveLocalEvent(event);
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      await _client.from('events').update({
        'name': event.name,
        'description': event.description,
        'is_active': event.isActive,
        'preset_items': event.presetItems.map((e) => e.toJson()).toList(),
      }).eq('id', event.id);
    } catch (e) {
      print('Update event error: $e');
      await _updateLocalEvent(event);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _client.from('events').delete().eq('id', eventId);
    } catch (e) {
      print('Delete event error: $e');
      await _deleteLocalEvent(eventId);
    }
  }

  Event _eventFromSupabase(Map<String, dynamic> data) {
    List<PresetItem> presetItems = [];
    if (data['preset_items'] != null) {
      presetItems = (data['preset_items'] as List)
          .map((e) => PresetItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Event(
      id: data['id'],
      name: data['name'],
      description: data['description'] ?? '',
      createdAt: DateTime.parse(data['created_at']),
      createdBy: data['created_by'] ?? '',
      isActive: data['is_active'] ?? true,
      presetItems: presetItems,
    );
  }

  // ==================== Transactions ====================

  Future<List<Transaction>> getTransactions() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return await _getLocalTransactions();

      final data = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => _transactionFromSupabase(e)).toList();
    } catch (e) {
      print('Get transactions error: $e');
      return await _getLocalTransactions();
    }
  }

  Future<List<Transaction>> getTransactionsByEvent(String eventId) async {
    try {
      final data = await _client
          .from('transactions')
          .select()
          .eq('event_id', eventId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => _transactionFromSupabase(e)).toList();
    } catch (e) {
      print('Get transactions by event error: $e');
      final allTransactions = await _getLocalTransactions();
      return allTransactions.where((t) => t.eventId == eventId).toList();
    }
  }

  Future<void> saveTransaction(Transaction transaction) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        await _saveLocalTransaction(transaction);
        return;
      }

      await _client.from('transactions').insert({
        'id': transaction.id,
        'user_id': userId,
        'event_id': transaction.eventId,
        'event_name': transaction.eventName,
        'items': transaction.items.map((e) => e.toJson()).toList(),
        'total_amount': transaction.totalAmount,
        'created_at': transaction.createdAt.toIso8601String(),
        'created_by': transaction.createdBy,
        'notes': transaction.notes,
      });
    } catch (e) {
      print('Save transaction error: $e');
      await _saveLocalTransaction(transaction);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _client.from('transactions').delete().eq('id', transactionId);
    } catch (e) {
      print('Delete transaction error: $e');
      await _deleteLocalTransaction(transactionId);
    }
  }

  Transaction _transactionFromSupabase(Map<String, dynamic> data) {
    return Transaction.fromJson({
      'id': data['id'],
      'eventId': data['event_id'],
      'eventName': data['event_name'],
      'items': data['items'],
      'totalAmount': data['total_amount'],
      'createdAt': data['created_at'],
      'createdBy': data['created_by'],
      'notes': data['notes'],
    });
  }

  // ==================== Local Storage Fallback ====================

  static const String _eventsKey = 'local_events';
  static const String _transactionsKey = 'local_transactions';

  Future<List<Event>> _getLocalEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);
    if (eventsJson != null) {
      final List<dynamic> eventsList = jsonDecode(eventsJson);
      return eventsList.map((e) => Event.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _saveLocalEvent(Event event) async {
    final events = await _getLocalEvents();
    events.add(event);
    await _saveLocalEvents(events);
  }

  Future<void> _updateLocalEvent(Event event) async {
    final events = await _getLocalEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await _saveLocalEvents(events);
    }
  }

  Future<void> _deleteLocalEvent(String eventId) async {
    final events = await _getLocalEvents();
    events.removeWhere((e) => e.id == eventId);
    await _saveLocalEvents(events);
  }

  Future<void> _saveLocalEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _eventsKey,
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<Transaction>> _getLocalTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString(_transactionsKey);
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = jsonDecode(transactionsJson);
      return transactionsList.map((e) => Transaction.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _saveLocalTransaction(Transaction transaction) async {
    final transactions = await _getLocalTransactions();
    transactions.add(transaction);
    await _saveLocalTransactions(transactions);
  }

  Future<void> _deleteLocalTransaction(String transactionId) async {
    final transactions = await _getLocalTransactions();
    transactions.removeWhere((t) => t.id == transactionId);
    await _saveLocalTransactions(transactions);
  }

  Future<void> _saveLocalTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _transactionsKey,
      jsonEncode(transactions.map((e) => e.toJson()).toList()),
    );
  }
}
