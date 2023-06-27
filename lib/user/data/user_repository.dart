import 'package:get_it/get_it.dart';

import 'package:gravity/_shared/types.dart';
import 'package:gravity/user/entity/user.dart';
import 'package:gravity/_shared/data/api_service.dart';

class UserRepository {
  final _apiService = GetIt.I<ApiService>();

  Future<User> createMyProfile() async {
    final data = await _apiService.mutate(
      query: '''
mutation CreateUser {
  insert_user_one(object: {display_name: "", description: ""}) {
    id
    uid
    display_name
    description
    has_picture
  }
}
''',
    );
    return User.fromJson(data['insert_user_one'] as Json);
  }

  Future<User> updateMyProfile({
    required String id,
    required String displayName,
    required String description,
    required bool hasPicture,
  }) async {
    final data = await _apiService.query(
      vars: {
        'id': id,
        'display_name': displayName,
        'description': description,
        'has_picture': hasPicture,
      },
      query: r'''
mutation UpdateUser($id: String!, $display_name: String!, $description: String!, $has_picture: Boolean!) {
  update_user_by_pk(pk_columns: {id: $id}, _set: {display_name: $display_name, description: $description, has_picture: $has_picture}) {
    id
    uid
    display_name
    description
    has_picture
  }
}
''',
    );
    if (data['update_user_by_pk'] == null) throw Exception('Can`t update');
    return User.fromJson(data['update_user_by_pk'] as Json);
  }

  Future<User?> getUserById(String userId) async {
    final data = await _apiService.query(
      vars: {'id': userId},
      query: r'''
query FetchUserProfile($id: String!) {
  user_by_pk(id: $id) {
    id
    uid
    display_name
    description
    has_picture
  }
}
''',
    );
    if (data['user_by_pk'] == null) return null;
    return User.fromJson(data['user_by_pk'] as Json);
  }
}
