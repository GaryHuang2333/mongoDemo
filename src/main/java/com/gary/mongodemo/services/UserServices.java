package com.gary.mongodemo.services;

import com.gary.mongodemo.dao.UserRepository;
import com.gary.mongodemo.entities.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class UserServices {
    @Autowired
    private UserRepository userRepository;

    public List<User> getAllUsers(){
        List<User> all = userRepository.findAll();
        return Optional.ofNullable(all).orElse(new ArrayList<>());
    }

    public void insertRandomUser(){
        User user = userRepository.findFirstByName("testUser1");
        user.setRandomName();
        user.renewObjectId();
        User insert = userRepository.insert(user);
    }

}
