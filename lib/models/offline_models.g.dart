// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyCacheAdapter extends TypeAdapter<SurveyCache> {
  @override
  final int typeId = 0;

  @override
  SurveyCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyCache(
      surveyId: fields[0] as int,
      title: fields[1] as String,
      slug: fields[2] as String,
      surveyData: (fields[3] as Map).cast<String, dynamic>(),
      version: fields[4] as int,
      lastUpdated: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyCache obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.surveyId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.surveyData)
      ..writeByte(4)
      ..write(obj.version)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnswerOfflineAdapter extends TypeAdapter<AnswerOffline> {
  @override
  final int typeId = 1;

  @override
  AnswerOffline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnswerOffline(
      surveyId: fields[0] as int,
      respondentId: fields[1] as String,
      enumeratorId: fields[2] as int,
      answers: (fields[3] as Map).cast<dynamic, dynamic>(),
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      isDirty: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AnswerOffline obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.surveyId)
      ..writeByte(1)
      ..write(obj.respondentId)
      ..writeByte(2)
      ..write(obj.enumeratorId)
      ..writeByte(3)
      ..write(obj.answers)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isDirty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerOfflineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final int typeId = 2;

  @override
  SyncQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItem(
      surveyId: fields[0] as int,
      respondentId: fields[1] as String,
      payload: (fields[2] as Map).cast<String, dynamic>(),
      status: fields[3] as String,
      createdAt: fields[4] as DateTime,
      retryCount: fields[5] as int,
      lastError: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.surveyId)
      ..writeByte(1)
      ..write(obj.respondentId)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.lastError);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
