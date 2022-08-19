package com.gary.mongodemo;

import com.gary.mongodemo.dao.UserRepository;
import com.gary.mongodemo.entities.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.List;

@SpringBootApplication
public class MongoCommandLineRunnerApplication implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    public static void main(String[] args) {
        SpringApplication.run(MongoCommandLineRunnerApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        List<User> allUsers = userRepository.findAll();
        System.out.println("list all existing users");
        for (User user : allUsers) {
            System.out.println(user);
        }
    }
}
