import imghdr
import os
import time
from typing import List
import numpy as np
import pandas as pd
from flask_cors import CORS
from PIL import Image
import tensorflow as tf
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from tensorflow.keras.preprocessing.image import load_img
from tensorflow.keras.preprocessing.image import img_to_array
from models.skin_tone.skin_tone_knn import identify_skin_tone
from flask import Flask, request
from flask_restful import Api, Resource, reqparse, abort
import werkzeug
from models.recommender.rec import recs_essentials, makeup_recommendation
import base64
from io import BytesIO
from PIL import Image

app = Flask(__name__)
CORS(app)
api = Api(app)

skin_tone_dataset = 'models/skin_tone/skin_tone_dataset.csv'


def load_image(img_path):
    img = image.load_img(img_path, target_size=(224, 224))
    # (height, width, channels)
    img_tensor = image.img_to_array(img)
    # (1, height, width, channels), add a dimension because the model expects this shape: (batch_size, height, width, channels)
    img_tensor = np.expand_dims(img_tensor, axis=0)
    # imshow expects values in the range [0, 1]
    img_tensor /= 255.
    return img_tensor


img_put_args = reqparse.RequestParser()
img_put_args.add_argument(
    "file", help="Please provide a valid image file", required=True)


rec_args = reqparse.RequestParser()

rec_args.add_argument(
    "tone", type=int, help="Argument required", required=True)

rec_args.add_argument("features", type=dict,
                      help="Argument required", required=True)

class Recommendation(Resource):
    def put(self):
        args = rec_args.parse_args()
        print(args)
        features = args['features']
        tone = args['tone']
        skin_type = args['type'].lower()
        skin_tone = 'light to medium'
        if tone <= 2:
            skin_tone = 'fair to light'
        elif tone >= 4:
            skin_tone = 'medium to dark'
        print(f"{skin_tone}, {skin_type}")
        fv = []
        for key, value in features.items():
            fv.append(int(value))

        general = recs_essentials(fv, None)

        makeup = makeup_recommendation(skin_tone, skin_type)
        return {'general': general, 'makeup': makeup}, 200

class SkinMetrics(Resource):
    def put(self):
        args = img_put_args.parse_args()
        print(args)
        file = args['file']
        starter = file.find(',')
        image_data = file[starter+1:]
        image_data = bytes(image_data, encoding="ascii")
        im = Image.open(BytesIO(base64.b64decode(image_data)))

        filename = 'image.png'
        file_path = os.path.join('./static', filename)
        im.save(file_path)

        tone = identify_skin_tone(file_path, dataset=skin_tone_dataset)

        print(tone)

        # Return skin tone as part of the response
        return {'tone': str(tone), 'message': 'Skin tone analysis successful'}, 200
api.add_resource(SkinMetrics, "/upload")
api.add_resource(Recommendation, "/recommend")


if __name__ == "__main__":
    app.run(debug=False, port=3001)

