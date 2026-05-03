# Demo data for local exploration (idempotent).
alice = User.find_or_initialize_by(email: "alice@example.com")
alice.assign_attributes(name: "Alice")
alice.save!

bob = User.find_or_initialize_by(email: "bob@example.com")
bob.assign_attributes(name: "Bob")
bob.save!

post = Post.find_or_initialize_by(title: "Welcome to the demo")
post.assign_attributes(
  user: alice,
  body: "This app was generated to show users, posts, and comments in Rails. Try adding a comment from the post page."
)
post.save!

unless post.comments.exists?(user: bob, body: "Great idea—this makes the relationships easy to see.")
  Comment.create!(user: bob, post: post, body: "Great idea—this makes the relationships easy to see.")
end
