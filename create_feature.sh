#!/bin/bash

# التأكد من إدخال اسم الفيتشر
if [ -z "$1" ]; then
  echo "Please provide a feature name. Example: ./create_feature.sh auth"
  exit 1
fi

FEATURE_NAME=$1
BASE_PATH="lib/features/$FEATURE_NAME"

echo "Creating Clean Architecture structure for feature: $FEATURE_NAME..."

# إنشاء مجلدات Data
mkdir -p "$BASE_PATH/data/datasources"
mkdir -p "$BASE_PATH/data/models"
mkdir -p "$BASE_PATH/data/repositories"

# إنشاء مجلدات Domain
mkdir -p "$BASE_PATH/domain/entities"
mkdir -p "$BASE_PATH/domain/repositories"
mkdir -p "$BASE_PATH/domain/usecases"

# إنشاء مجلدات Presentation
mkdir -p "$BASE_PATH/presentation/bloc"
mkdir -p "$BASE_PATH/presentation/pages"
mkdir -p "$BASE_PATH/presentation/widgets"

echo "Done! Feature '$FEATURE_NAME' created successfully."