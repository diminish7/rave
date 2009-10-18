#Display usage for rave command
def display_usage
  puts "Useage: rave [create | server | war] [robot_name] [options]"
  puts "'create' generates a Google Wave robot client stub application."
  puts "e.g."
  puts "rave create my_robot image_url=http://my_robot.appspot.com/image.png profile_url=http://my_robot.appspot.com/"
  puts "'server' launches the robot"
  puts "e.g."
  puts "rave server"
  puts "'war' creates a war file suitable for deploying to Google AppEngine"
  puts "e.g."
  puts "rave war"
end