// add shards to cluster
print('');
print('#### add shards to cluster');
sh.addShard("mongodS0/myMongodS0N1:27017,myMongodS0N2:27017,myMongodS0N3:27017");
sh.addShard("mongodS1/myMongodS1N1:27017,myMongodS1N2:27017,myMongodS1N3:27017");
sh.addShard("mongodS2/myMongodS2N1:27017,myMongodS2N2:27017,myMongodS2N3:27017");

// health check DB before image
print('');
print('#### health check DB before image');
print(db.adminCommand('listDatabases'));

// prepare data
print('');
print('#### prepare data');
// use userDB;
db = db.getSiblingDB("userDB");
sh.enableSharding("userDB");
sh.shardCollection("userDB.user", {name:"hashed"});
db.user.insertOne({name:"test"});
db.user.insertOne({name:"testUser1", age:18, gender:"male", hobbies:"testHobby1,testHobby2,testHobby3", fans:"testUser2,testUser3,testUser4", fansNum:3, followings:"testUser2,testUser5,testUser6", followingsNum:3, like:"", favourite:"", blogsIds:"testBlog1,testBlog2,testBlog3,testBlog4,testBlog5", blogsNum:5});
db.user.insertOne({name:"testUser2", age:19, gender:"female", hobbies:"testHobby4,testHobby5,testHobby6", fans:"testUser1,testUser4", fansNum:2, followings:"testUser1,testUser5", followingsNum:2, like:"testBlog1", favourite:"testBlog1", blogsIds:"", blogsNum:0});
db.user.insertOne({name:"testUser3", age:20, gender:"male", hobbies:"testHobby7,testHobby8,testHobby9", fans:"", fansNum:0, followings:"testUser1,testUser4,testUser5", followingsNum:3, like:"", favourite:"", blogsIds:"", blogsNum:0});
db.user.insertOne({name:"testUser4", age:21, gender:"female", hobbies:"testHobby1,testHobby4,testHobby7", fans:"testUser3,testUser5", fansNum:2, followings:"testUser1,testUser2,testUser3,testUser5", followingsNum:4, like:"", favourite:"", blogsIds:"", blogsNum:0});
db.user.insertOne({name:"testUser5", age:22, gender:"male", hobbies:"testHobby2,testHobby5,testHobby8", fans:"testUser2,testUser1,testUser3,testUser4,testUser6", fansNum:5, followings:"testUser1,testUser2,testUser3,testUser4", followingsNum:4, like:"", favourite:"", blogsIds:"", blogsNum:0});
db.user.insertOne({name:"testUser6", age:23, gender:"female", hobbies:"testHobby3,testHobby6,testHobby9", fans:"testUser1", fansNum:1, followings:"testUser1,testUser5", followingsNum:1, like:"testBlog1", favourite:"testBlog1", blogsIds:"", blogsNum:0});
db.admin.insertOne({name:"testAdmin1"});

// use blogDB;
db = db.getSiblingDB('blogDB');
sh.enableSharding("blogDB");
sh.shardCollection("blogDB.blog", {blogId:"hashed"});
db.blog.insertOne({blogId:"test"});
db.blog.insertOne({blogId:"testBlog1", tittle:"testBlog1Tittle", author:"testUser1", createTS: new Date(), modifyTS: new Date(), content: "testBlog1Content", beRepostedNum:0, beLikedNum:0});
db.blog.insertOne({blogId:"testBlog2", tittle:"testBlog2Tittle", author:"testUser1", createTS: new Date(), modifyTS: new Date(), content: "testBlog2Content", beRepostedNum:0, beLikedNum:0});
db.blog.insertOne({blogId:"testBlog3", tittle:"testBlog3Tittle", author:"testUser1", createTS: new Date(), modifyTS: new Date(), content: "testBlog3Content", beRepostedNum:0, beLikedNum:0});
db.blog.insertOne({blogId:"testBlog4", tittle:"testBlog4Tittle", author:"testUser1", createTS: new Date(), modifyTS: new Date(), content: "testBlog4Content", beRepostedNum:0, beLikedNum:0});
db.blog.insertOne({blogId:"testBlog5", tittle:"testBlog5Tittle", author:"testUser1", createTS: new Date(), modifyTS: new Date(), content: "testBlog5Content", beRepostedNum:0, beLikedNum:0});

// health check DB after image
print('');
print('#### health check DB after image');
print(db.adminCommand('listDatabases'));