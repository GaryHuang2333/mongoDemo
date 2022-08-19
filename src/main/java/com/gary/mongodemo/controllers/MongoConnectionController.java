package com.gary.mongodemo.controllers;

import com.gary.mongodemo.entities.User;
import com.gary.mongodemo.services.UserServices;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
public class MongoConnectionController {
    @Autowired
    private UserServices userServices;

    @GetMapping("/allUsers")
    public String getAllUsers(){
        String result = "";
        List<User> allUsers = userServices.getAllUsers();
        result = allUsers.stream().map(user -> user.toString()).collect(Collectors.joining(";\n"));
        return result;
    }

    @GetMapping("/insertRandom")
    public String insertRandomUser(){
        String result = "insert random user";
        userServices.insertRandomUser();
        return result;
    }

}
