# Model classes
A model class represents a data structure returned from an API. By using model classes, we can intentionally make changes when API responses change, and react and validate payloads.

## Base class features
- Reserved key replacement
    - When deserializing JSON to an Apex object, there is a high chance of keyword collisions (for example, a currency value would throw an error). There is a keyword map that is replaced by the base class, if a reserved keyword is found in a new payload, extend the map to support it.
- Serialization
    - The model can be converted into a JSON string, if we ever need to send a PUT/POST/PATCH we can use this capability to build a JSON body.
- Deserialization
    - Converts a JSON String into a model. To be used with an API response to build a model.
