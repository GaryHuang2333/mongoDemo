package com.gary.mongodemo.maintest.entities;

import java.util.List;

/**
 *       - user
 *               - name : string
 *               - age : int ([0,120])
 *               - gender : string (male/female)
 *               - hobbies : string (list of hobbies, seperated by ",")
 *               - fans : string (list of usernames, seperated by ",")
 *               - fansNum : int
 *               - followings : string (list of usernames, seperated by ",")
 *               - followingsNum : int
 *               - like : string (list of blog id, seperated by ",")
 *               - favourite : string (list of blog id, seperated by ",")
 *               - blogsIds : string (list of posted blog id, repost is included, seperated by ",")
 *               - blogsNum : int
 */
public class User {
    private String name;
    private int age;
    private String gender;
    private String hobbies;
    private String fans;
    private int fansNum;
    private String followings;
    private int followingNum;
    private String like;
    private String favourite;
    private String blogsIds;
    private int blogsNum;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getHobbies() {
        return hobbies;
    }

    public void setHobbies(String hobbies) {
        this.hobbies = hobbies;
    }

    public String getFans() {
        return fans;
    }

    public void setFans(String fans) {
        this.fans = fans;
    }

    public int getFansNum() {
        return fansNum;
    }

    public void setFansNum(int fansNum) {
        this.fansNum = fansNum;
    }

    public String getFollowings() {
        return followings;
    }

    public void setFollowings(String followings) {
        this.followings = followings;
    }

    public int getFollowingNum() {
        return followingNum;
    }

    public void setFollowingNum(int followingNum) {
        this.followingNum = followingNum;
    }

    public String getLike() {
        return like;
    }

    public void setLike(String like) {
        this.like = like;
    }

    public String getFavourite() {
        return favourite;
    }

    public void setFavourite(String favourite) {
        this.favourite = favourite;
    }

    public String getBlogsIds() {
        return blogsIds;
    }

    public void setBlogsIds(String blogsIds) {
        this.blogsIds = blogsIds;
    }

    public int getBlogsNum() {
        return blogsNum;
    }

    public void setBlogsNum(int blogsNum) {
        this.blogsNum = blogsNum;
    }

    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                ", age=" + age +
                ", gender='" + gender + '\'' +
                ", hobbies='" + hobbies + '\'' +
                ", fans='" + fans + '\'' +
                ", fansNum=" + fansNum +
                ", followings='" + followings + '\'' +
                ", followingNum=" + followingNum +
                ", like='" + like + '\'' +
                ", favourite='" + favourite + '\'' +
                ", blogsIds='" + blogsIds + '\'' +
                ", blogsNum=" + blogsNum +
                '}';
    }
}