# WhetStone

A generic data parsing utility. 

This project aims at exemplifying a csv based static data distribution format, 
which can be used by individuals to filter and get specific records.


Idea is to have a central app and a database where data is posted which is then 
fetched and parsed for the user. User can filter data to get desired results.


# Prefered Use

- Bunch of static databases which are relevant to users are accessed by user and stored locally for further requirements.


# TODO 

- Add limit of around 100-1000 access codes storage.
- Add LRU based rotation of array for elimination.
- Provide Comparable Functionality in filters alongside Equatable.
