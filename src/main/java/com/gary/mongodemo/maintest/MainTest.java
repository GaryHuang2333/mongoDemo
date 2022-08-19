package com.gary.mongodemo.maintest;

import com.gary.mongodemo.maintest.entities.Blog;

import com.gary.mongodemo.maintest.entities.User;
import com.mongodb.client.*;
import org.bson.Document;

import static com.mongodb.MongoClientSettings.getDefaultCodecRegistry;
import static org.bson.codecs.configuration.CodecRegistries.fromProviders;
import static org.bson.codecs.configuration.CodecRegistries.fromRegistries;
import org.bson.codecs.configuration.CodecProvider;
import org.bson.codecs.configuration.CodecRegistry;
import org.bson.codecs.pojo.PojoCodecProvider;

public class MainTest {
    public static void main(String[] args) {
        mongoConnection();
    }

    public static void mongoConnection(){
        System.out.println("\n\n#######################################");
        System.out.println("#### rawConnection");
        rawConnection();
        System.out.println("\n\n#######################################");
        System.out.println("#### codecConnection");
        codecConnection();
    }

    public static void rawConnection() {
//        String uri = "mongodb://myMongos1:27017,myMongos2:27017,myMongos3:27017";  // failed as not setup in local /etc/hosts
        String uri = "mongodb://localhost:8081,localhost:8082,localhost:8083";
        MongoClient mongoClient = MongoClients.create(uri);

        System.out.println("#### GT get users in userDB");
        MongoDatabase userDB = mongoClient.getDatabase("userDB");
        MongoCollection<Document> users = userDB.getCollection("user");
        MongoCursor<Document> userCursor = users.find().iterator();
        while (userCursor.hasNext()) {
            Document user = userCursor.next();
            System.out.println(user.toJson());
        }

        System.out.println("#### GT get blogs in blogDB");
        MongoDatabase blogDB = mongoClient.getDatabase("blogDB");
        MongoCollection<Document> blogs = blogDB.getCollection("blog");
        MongoCursor<Document> blogCursor = blogs.find().iterator();
        while (blogCursor.hasNext()) {
            Document blog = blogCursor.next();
            System.out.println(blog.toJson());
        }
    }

    public static void codecConnection() {
//        String uri = "mongodb://myMongos1:27017,myMongos2:27017,myMongos3:27017";  // failed as not setup in local /etc/hosts
        String uri = "mongodb://localhost:8081,localhost:8082,localhost:8083";
        MongoClient mongoClient = MongoClients.create(uri);

        CodecProvider pojoCodecProvider = PojoCodecProvider.builder().automatic(true).build();
        CodecRegistry pojoCodecRegistry = fromRegistries(getDefaultCodecRegistry(), fromProviders(pojoCodecProvider));


        System.out.println("#### GT get users in userDB");
        MongoDatabase userDB = mongoClient.getDatabase("userDB").withCodecRegistry(pojoCodecRegistry);
        MongoCollection<User> users = userDB.getCollection("user", User.class);
        MongoCursor<User> userCursor = users.find().iterator();
        while (userCursor.hasNext()) {
            User user = userCursor.next();
            System.out.println(user);
        }

        System.out.println("#### GT get blogs in blogDB");
        MongoDatabase blogDB = mongoClient.getDatabase("blogDB").withCodecRegistry(pojoCodecRegistry);
        MongoCollection<Blog> blogs = blogDB.getCollection("blog", Blog.class);
        MongoCursor<Blog> blogCursor = blogs.find().iterator();
        while (blogCursor.hasNext()) {
            Blog blog = blogCursor.next();
            System.out.println(blog);
        }
    }
}
