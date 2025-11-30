import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../state/profile_controller.dart';
import '../../../../core/errors/faillures.dart';

/// Page de profil.
class ProfilePage extends StatelessWidget {
  final String userId;
  final String token;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final state = controller.state;

    // Si rien n'a été chargé encore, on lance le load au premier build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.isLoading && !state.hasUser && state.failure == null) {
        controller.loadProfile(userId: userId, token: token);
      }
    });

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.failure != null) {
      final Failure failure = state.failure!;
      final message = profileFailureToMessage(failure);

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  controller.loadProfile(userId: userId, token: token),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (!state.hasUser) {
      return const Center(child: Text('Aucune donnée de profil.'));
    }

    final user = state.user as UserModel;

    return _ProfileContent(
      user: user,
      onRefresh: () {
        controller.refreshProfile(userId: userId, token: token);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh;

  const _ProfileContent({
    required this.user,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
