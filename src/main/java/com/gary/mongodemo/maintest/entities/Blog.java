package com.gary.mongodemo.maintest.entities;

import java.util.Date;

/**
 *       - blog
 *         - blogId : string
 *         - tittle : string (encrypted for small size)
 *         - author : string
 *         - createTS : timestamp
 *         - modifyTS : timestamp
 *         - content : string (encrypted for small size)
 *         - beRepostedNum : int
 *         - beLikedNum : int
 */
public class Blog {
    private String blogId;
    private String tittle;
    private String author;
    private Date createTS;
    private Date modifyTS;
    private String content;
    private int beRepostedNum;
    private int beLikedNum;

    public String getBlogId() {
        return blogId;
    }

    public void setBlogId(String blogId) {
        this.blogId = blogId;
    }

    public String getTittle() {
        return tittle;
    }

    public void setTittle(String tittle) {
        this.tittle = tittle;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public Date getCreateTS() {
        return createTS;
    }

    public void setCreateTS(Date createTS) {
        this.createTS = createTS;
    }

    public Date getModifyTS() {
        return modifyTS;
    }

    public void setModifyTS(Date modifyTS) {
        this.modifyTS = modifyTS;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getBeRepostedNum() {
        return beRepostedNum;
    }

    public void setBeRepostedNum(int beRepostedNum) {
        this.beRepostedNum = beRepostedNum;
    }

    public int getBeLikedNum() {
        return beLikedNum;
    }

    public void setBeLikedNum(int beLikedNum) {
        this.beLikedNum = beLikedNum;
    }

    @Override
    public String toString() {
        return "Blog{" +
                "blogId='" + blogId + '\'' +
                ", tittle='" + tittle + '\'' +
                ", author='" + author + '\'' +
                ", createTS=" + createTS +
                ", modifyTS=" + modifyTS +
                ", content='" + content + '\'' +
                ", beRepostedNum=" + beRepostedNum +
                ", beLikedNum=" + beLikedNum +
                '}';
    }
}

