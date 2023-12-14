part of 'media_bloc.dart';

@immutable
sealed class MediaEvent {}

class InitiateMediaUpload extends MediaEvent {
  final String bucketId;
  final String poolId;

  InitiateMediaUpload({
    required this.bucketId,
    required this.poolId,
  });
}

class UploadFile extends MediaEvent {}
