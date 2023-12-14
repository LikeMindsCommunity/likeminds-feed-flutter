import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_s3/simple_s3.dart';

part 'media_event.dart';
part 'media_state.dart';
part 'handler/upload_file_event_handler.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  late final String _bucketName;
  late final String _poolId;
  final _region = AWSRegions.apSouth1;
  final SimpleS3 _s3Client = SimpleS3();

  MediaBloc() : super(MediaInitial()) {
    on<InitiateMediaUpload>(uploadFileHandler);
  }
}
