#!/usr/bin/env python
# coding: utf-8

# In[1]:


import tensorflow as tf
import matplotlib.pyplot as plt
import cv2
import os
import numpy as np
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.preprocessing import image
from tensorflow.keras.optimizers import RMSprop


# In[2]:


train = ImageDataGenerator(rescale = 1/255)
validation = ImageDataGenerator(rescale = 1/255)


# In[5]:


train_dataset = train.flow_from_directory("C:/Users/Dell/Downloads/skin_type/train/",
                                         target_size=(200, 200),
                                         batch_size=3,
                                         class_mode='categorical')

validation_dataset = train.flow_from_directory("C:/Users/Dell/Downloads/skin_type/validation/",
                                         target_size=(200, 200),
                                         batch_size=3,
                                         class_mode='categorical')


# In[6]:


train_dataset.class_indices


# In[7]:


model = tf.keras.models.Sequential([ tf.keras.layers.Conv2D(16,(3,3), activation = 'relu', input_shape = (200,200,3)),
                                    tf.keras.layers.MaxPool2D(2,2),
                                    #
                                    tf.keras.layers.Conv2D(32,(3,3), activation = 'relu'),
                                    tf.keras.layers.MaxPool2D(2,2),
                                    #
                                    tf.keras.layers.Conv2D(64,(3,3), activation = 'relu'),
                                    tf.keras.layers.MaxPool2D(2,2),
                                    ##
                                    tf.keras.layers.Flatten(),
                                    ##
                                    tf.keras.layers.Dense(512,activation= 'relu'),
                                    ##
                                    tf.keras.layers.Dense(3,activation='softmax')
                                    
                                    
    
])


# In[8]:


model.compile(loss= 'categorical_crossentropy',
             optimizer = RMSprop(learning_rate=0.001),
              metrics = ['accuracy']
             )


# In[9]:


try:
    model_fit = model.fit(
        train_dataset,
        steps_per_epoch=len(train_dataset),
        epochs=10,
        validation_data=validation_dataset
    )
except Exception as e:
    print("Error during training:", e)


# In[10]:
    
    model.save('skin_type_trained_model.h5')

# Convert the model to TensorFlow Lite format
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the TensorFlow Lite model to a file
with open('skintype_trained_model.tflite', 'wb') as f:
    f.write(tflite_model)



dir_path = 'C:/Users/Dell/Downloads/skin_type/test'

for i in os.listdir(dir_path):
    img_path = os.path.join(dir_path, i)
    img = image.load_img(img_path, target_size=(200, 200))
    plt.imshow(img)
    plt.show()

    X = image.img_to_array(img)
    X = np.expand_dims(X, axis=0)
    images = np.vstack([X])
    val = model.predict(images)

    predicted_class = np.argmax(val)  # Get the index of the highest probability class

    if predicted_class == 0:
        print('Skin Type: Dry')
    elif predicted_class == 1:
        print('Skin Type: Normal')
    else:
        print('Skin Type: Oily')


# In[ ]:




