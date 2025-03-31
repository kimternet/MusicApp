import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/features/auth/model/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository();
}

class AuthRemoteRepository {
  final logger = Logger();
  Future<Either<AppFailure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.serverUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      logger.i('Response body: ${response.body}');
      logger.i('Status code: ${response.statusCode}');

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201) {
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(UserModel.fromMap(resBodyMap));
    } catch (e) {
      logger.e('Error: $e');
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData(String token) async {
    try {
      logger.i('Fetching user data with token: $token');
      logger.i('URL: ${ServerConstant.serverUrl}/auth/');
      
      final response = await http.get(
        Uri.parse('${ServerConstant.serverUrl}/auth/'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token
        },
      );
      
      logger.i('Response status: ${response.statusCode}');
      logger.i('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        try {
          final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
          logger.e('Error response: $resBodyMap');
          return Left(AppFailure(resBodyMap['detail'] ?? 'Failed to get user data'));
        } catch (e) {
          logger.e('Failed to parse error response: $e');
          return Left(AppFailure('Invalid server response with status: ${response.statusCode}'));
        }
      }
      
      try {
        final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
        logger.i('Parsed response: $resBodyMap');
        
        // 서버 응답 형식에 따라 처리 방식 변경
        final user = UserModel.fromMap(
          resBodyMap['user'] != null 
            ? resBodyMap['user'] as Map<String, dynamic>
            : resBodyMap,
        ).copyWith(
          token: resBodyMap['token'] ?? token,
        );
        logger.i('User created: ${user.name}');
        
        return Right(user);
      } catch (e) {
        logger.e('Error parsing response: $e');
        return Left(AppFailure('Failed to parse server response: ${e.toString()}'));
      }
    } catch (e) {
      logger.e('Error in getCurrentUserData: $e');
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      logger.i('Login attempt for email: $email');
      final response = await http.post(
        Uri.parse('${ServerConstant.serverUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      logger.i('Login response status: ${response.statusCode}');
      logger.i('Login response body: ${response.body}');
      
      if (response.statusCode != 200) {
        final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail'] ?? 'Login failed'));
      }
      
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      logger.i('Login parsed response: $resBodyMap');
      
      // 서버 응답 형식에 따라 처리 방식 변경
      final user = UserModel.fromMap(
        resBodyMap['user'] != null 
          ? resBodyMap['user'] as Map<String, dynamic>
          : resBodyMap,
      ).copyWith(
        token: resBodyMap['token'],
      );
      logger.i('User logged in: ${user.name}');
      
      return Right(user);
    } catch (e) {
      logger.e('Error during login: $e');
      return Left(AppFailure(e.toString()));
    }
  }
}
