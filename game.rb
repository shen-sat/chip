require 'json'
require 'gosu'
require 'gosu_tiled'

#sets the directory to where the game is located *DELETE IF NECCESSARY*
Dir.chdir "c:/"
Dir.chdir "users/shen/desktop/workspace/chip"

class Game_Window < Gosu::Window
  
  def initialize
    #sets up the window space and title
	super(384, 208, false)
    self.caption = "Chip"
	#loads images from Tiled *DELETE IF NECCESSARY*
	@background_images = Gosu::Tiled.load_json(self, "media/landscape.json")
	
	
	#loads the json file exported from Tiled and extracts the collider layer into an array
	file = File.read("media/landscape.json")
	data_hash = JSON.parse(file)
	landcsape_colliders = []
	data_hash["layers"].each do |x|
		if x["name"] == "colliders"
			landcsape_colliders =  x["objects"]
		end
	end
	
	@hero = Player.new
	#set the starting point for the player. 
	#Note: the values set here will ultimately pass to the .draw method which sets image's origin at the top-left corner. 
	@hero.warp(0,164)
	
 end

  
  def update
	#check for bottom collisions
	@hero.bottom_border_collision_check
	
	#if player is jumping, continue jump
	if @hero.jumping
		@hero.jump
	end
	
	#if right arrow pressed run right method. If space pressed then run jump method too. 
	if Gosu.button_down? Gosu::KB_RIGHT
			@hero.right
			if Gosu.button_down? Gosu::KB_SPACE
				if @hero.bottom_border_collision_check
					@hero.start_jump
				end
			end	
	#if left arrow pressed run left method. If space pressed then run jump method too. 
	elsif Gosu.button_down? Gosu::KB_LEFT
		@hero.left
		if Gosu.button_down? Gosu::KB_SPACE
				if @hero.bottom_border_collision_check
					@hero.start_jump
				end
			end
	elsif
		Gosu.button_down? Gosu::KB_SPACE
			#only if player is on contact with ground can player jump
			if @hero.bottom_border_collision_check
				@hero.start_jump
			end
	end
  end
  
  
  
  def draw
	@background_images.draw(0,0)
	@hero.draw
  end
end

class Player
	attr_reader :jumping
	
	def initialize
		@dummy_image = Gosu::Image.new("media/dummy_trans.png", :tileable => true)
		#set width of character sprite
		@width = 22
		@height = 28
		@lateral_speed = 3
		@up_speed = @up_speed_constant = -9
		@gravity = 1
		@jumping = false
		
	end
	
	def warp(x,y)
		#The .warp values from initialise give the top left corner of the player image 
		#The following code calculates the centre of the coordinates of player image, which are easier to use for further calculations
		@x = x + (@width/2)		
		@y = y +(@height/2)
		
	end
	
	#check if bottom border of player is in touch with ground
	def bottom_border_collision_check
		@bottom_border = @y + (@height/2)
		if @bottom_border >= 192
			@bottom_border_collision = true
		else
			@bottom_border_collision = false	
		end
	@bottom_border_collision
	end
	
	def start_jump
		@y += @up_speed
		puts @bottom_border
		@jumping = true
	end
	
	def jump
		if @bottom_border_collision == false
			@y += @up_speed
			@up_speed += @gravity
		else
			@y = 178
			@jumping = false
			@up_speed = @up_speed_constant
		end
	end
	
	def right
		@x += @lateral_speed
	end
	
	def left
		@x -= @lateral_speed
	end
		
	def draw
		#.draw always draws an image from its top-left corner. We therefore can't pass it @x and @y because these are the player's centre coordinates.
		#We therefore modify @x and @y to give the image's top-left corner coordinates
		@dummy_image.draw(@x - (@width/2), @y - (@height/2), 10)
		
	end
end

game_window = Game_Window.new
game_window.show