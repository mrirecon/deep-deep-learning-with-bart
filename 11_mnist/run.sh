cd $REPO/11_mnist

# Training
bart mnist -g -t train_images weights train_labels

# Inference
bart extract 2 0 10 test_images images 
bart mnist -a images weights prediction
bart onehotenc -r prediction label

## Print first 10 predictions
echo Prediction:
bart show label
