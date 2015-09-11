
# Zhenyu Han
# COSI105B Learn Ruby the Hard Way
# 9/7/2015
# Homework for PA-movies Part 1

class MovieData
	attr_accessor :data_of_movies, :test_data
	def initialize
		@data_of_movies = []
		@test_data_movies = []
		load_train(load_data("ml-100k/u1.base"))
		load_test(load_data("ml-100k/u1.test"))
	end

	def access_train
		@data_of_movies
	end

	def access_test
		@test_data_movies
	end

	# load the data
	def load_data(name)
		# read the data from the file
		movie_data = open(name,"r")

		# separate the data into 4 lists, each line was separated by the tab
		n = 0
		data_lst, user_id_list, movie_id_list, rating_list, time_stamp_list = [], [], [], [], [] ### code smell

		movie_data.each do |single_one|
			data = single_one.split("\t")
			user_id_list[n] = data[0].to_i
			movie_id_list[n] = data[1].to_i
			rating_list[n] = data[2].to_i
			time_stamp_list[n] = data[3].to_i
			n += 1
		end
		data_lst[0] = user_id_list
		data_lst[1] = movie_id_list
		data_lst[2] = rating_list
		data_lst[3] = time_stamp_list
		return data_lst
	end

	# assign the instance variable @data_of_movies with all the data
	def load_train(lst)
		@data_of_movies[0] = lst[0]
		@data_of_movies[1] = lst[1]
		@data_of_movies[2] = lst[2]
		@data_of_movies[3] = lst[3]
	end

	def load_test(lst)
		@test_data_movies[0] = lst[0]
		@test_data_movies[1] = lst[1]
		@test_data_movies[2] = lst[2]
		@test_data_movies[3] = lst[3]
	end

	# popularity is simply the number of people watched the movie
	def popularity(movie_id)
		contain_or_not = @data_of_movies[1].include?(movie_id)

		# check if the movie is contained in this data set
		if contain_or_not
			n = 0
			@data_of_movies[1].each do |single|
				if single == movie_id
					n += 1
				end
			end
			return n  # popularity is calculated simply the numbers that people who has watched it
		else
			return "Sorry, we can't find this movie in this data set!"
		end

	end

	#check the popularity by counting the numbers that a certain movie shown in movie_id_list
	def popularity_list
		movie_id_list = @data_of_movies[1]

		# count each movie and save as a dictionary, hash actually
		counts = Hash.new(0)
		movie_id_list.each { |movie_id_list| counts[movie_id_list] += 1 }

		# sort the hash by decreasing
		decreasing_popularity = Hash[counts.sort_by{|k,v| v}.reverse]

		return decreasing_popularity
	end

	# check the similarity of the two users
	def similarity(user1,user2)
		user1_lst, user2_lst = similarity_helper(user1, user2)
		# store the common movies watched by these two users
		n = 0
		user1_lst.each do |user1_elem|
			user2_lst.each do |user2_elem|
				if user1_elem == user2_elem
					n += 1
				end
			end
		end
		# similarity is calculated by the number of the same movies they watched divided by
		#	all the movies they two have watched, so it should be within [0,1]
		similarity = n.fdiv(user1_lst.length + user2_lst.length - n)
		return similarity
	end

	def similarity_helper(user1, user2)
		user1_lst, user2_lst = [], []
		user_id_lst = @data_of_movies[0]
		movie_id_lst = @data_of_movies[1]

		# store the movies watched by each of the two users
		user_id_lst.each_with_index do |user_id, index|
			if user_id == user1
				user1_lst.push(movie_id_lst[index])
			end
			if user_id == user2
				user2_lst.push(movie_id_lst[index])
			end
		end
		return user1_lst, user2_lst
	end


	# check similarity of a given u and return a list of top 10
	def most_similar(u)
		user_id = find_user_id

		# calculate the similarity of user 'u' with everyone else, store in hash named all_similar

		all_similar = {}
		user_id.each do |single_user|
			if single_user != u
				sim_val = similarity(u, single_user)
				all_similar[single_user] = sim_val
			end
		end

		# sort the similarity as required, top ten as shown
		decreasing_simi = Hash[all_similar.sort_by{|k,v| v}.reverse]
		most_similar = Hash[decreasing_simi.sort_by { |k,v| -v }[0..9]]

		return most_similar
	end


	# find all the users and put them into a list
	def find_user_id
		user_id_lst = @data_of_movies[0]

		user_lst = []
		user_id_lst.each do |user_id|
			if !user_lst.include?(user_id)
				user_lst.push(user_id)
			end
		end

		return user_lst
	end

	############### Here are the part for PA2 ################

	# reads the user_id and movie_id, return the actually rating that the viewer gave
	def rating(user, movie)

		user_lst = []
		movie_lst = []

		@data_of_movies[0].each_with_index do |item, index| # user_id list
			if item == user
				user_lst.push(index)
			end
		end

		@data_of_movies[1].each_with_index do |item, index| # movie_id list
			if item == movie
				movie_lst.push(index)
			end
		end

		index_rating = user_lst & movie_lst
		return @data_of_movies[2][index_rating[0]]
	end

	# this predict is calcualted by the average of the viewer's rating and
	# 		the movie's average rating
	def predict(user, movie)
		r_l_user = rating_count(user, @data_of_movies[0])
		r_l_movie = rating_count(movie, @data_of_movies[1])
		return (predict_helper(r_l_movie)+predict_helper(r_l_user))/2.0
	end

	def predict_helper(lst)
		num, prediction = 0, 0
		lst.each {|itm| num+= itm}
		rand_num = Random.new
		case rand_num.rand(num)
		when 0..lst[0] then prediction = 0
		when lst[0]..lst[0]+lst[1] then prediction = 1
		when lst[0]+lst[1]..lst[0]+lst[1]+lst[2] then prediction = 2
		when lst[0]+lst[1]+lst[2]..lst[0]+lst[1]+lst[2]+lst[3] then prediction = 3
		when lst[0]+lst[1]+lst[2]+lst[3]..num-lst[-1] then prediction = 4
		else
			prediction = 5
		end
		return prediction
	end

	# reads the user_id and return a list of the movies that he/she watched
	def movies(user)
		return movie_viewer_helper(user,@data_of_movies[0],@data_of_movies[1])
	end

	# reads the movie_id and return a list of viewers who watched it
	def viewers(movie)
		return movie_viewer_helper(movie, @data_of_movies[1],@data_of_movies[0])
	end
	def movie_viewer_helper(name,lst1, lst2)
		return_lst = []
		lst1.each_with_index do |item, index|
			if item == name
				return_lst.push(lst2[index])
			end
		end
		return return_lst
	end

	# get the first k of user from test file and return as a tuple cotainning:
	# 		user_id, movie_id, rating, prediction
	def run_test(k)
		tuple_lst, first_k = [], []
		tuple_lst[0] = @test_data_movies[0][0..k-1]
		tuple_lst[1] = @test_data_movies[1][0..k-1]
		tuple_lst[2] = @test_data_movies[2][0..k-1]

		num = 0
		while num < k do
			first_k.push(predict(@test_data_movies[0][num],@test_data_movies[1][num]))
			num += 1
		end
		tuple_lst[3] = first_k
		return tuple_lst
	end

	# This method was designed to help analyze the distribution of all the
	# 		rating of a certain user
	def rating_count(user,user_lst)
		rating_lst = [0,0,0,0,0,0]
		# find the distribution of the ratings of a certain user

		user_lst.each_with_index do |item, index|
			if item == user
				rating = @data_of_movies[2][index]
				case rating
				when 1
					rating_lst[1]+= 1
				when 2
					rating_lst[2]+= 1
				when 3
					rating_lst[3]+= 1
				when 4
					rating_lst[4]+= 1
				when 5
					rating_lst[5]+= 1
				else
					rating_lst[0]+= 1
				end
			end
		end
		return rating_lst
	end

	# this method was designed to help predict the rating by
	# 		calculate the average rating of all the viewers
	def movie_rating_average(movie)
		num = 0
		total_rating = 0
		@data_of_movies[1].each_with_index do |item, index|
			if item = movie
				num += 1
				total_rating += @data_of_movies[2][index]
			end
		end
		return total_rating.to_f / num
	end

# end of the MovieData class
end


######## MovieTest ########

class MovieTest
	attr_accessor :test_sample, :fix_k, :mean_err

	def initialize(k)
		@fix_k = k
		@test_sample = MovieData.new.run_test(k)
		@mean_error = cal_mean_error
	end

	# caluculate the average predication error
	def cal_mean_error
		tot_err = 0
		@test_sample[3].each_with_index do |item, index|
			err = @test_sample[2][index] - item
			tot_err += err
		end
		return tot_err.to_f / @fix_k
	end

	# calcualte the standard deviation of the error
	def stddev
		sum = 0
		@test_sample[3].each do |item|
			sum += (item - @mean_error) * (item - @mean_error)
		end
		return Math.sqrt(sum / @fix_k)
	end

	# calculate the root mean square error of the prediction
	def cal_rms
		mean = cal_rms_helper

		sum_sec = 0
		@test_sample[3].each do |item|
			sum_sec += (item - mean)*(item - mean)
		end
		return Math.sqrt(sum_sec / @fix_k)
	end

	def cal_rms_helper
		sum = 0
		@test_sample[3].each do |item|
			sum += item
		end
		return sum.to_f / @fix_k
	end

	def to_a
		@test_sample
	end
end


########### just ignore the following part, for self-check only ############

# check the popularity method
movies_data = MovieData.new
#p movies_data.access_train[0].length
#p movies_data.access_test[1].length
#popularity = movies_data.popularity(12)
#puts "Here is the popularity of movie 12: #{popularity}"

# check the popularity_list method
#popularity_lst = movies_data.popularity_list
#puts "Here is  the popularity list: #{popularity_lst}"

# check the similarity() method
#similarity = movies_data.similarity(12,13)
#puts "here is the similarity: #{similarity}"

# check the most_similarity() method
#most_lst = movies_data.most_similar(12)
#puts "Here is the most similar list with movie 12: #{most_lst}"

# check the rating(u,m) method
#rat = movies_data.rating(12, 203)
#p rat

# check the predict(u,m) method
#pred = movies_data.predict(12,203)
#p pred

# check the movies(u) method
#mov = movies_data.movies(12)
#p mov

# check the viewers(m) method
#view = movies_data.viewers(203)
#p view
###### end ########

# check the run_test(k) method
#ta = Time.now
#first_k = movies_data.run_test(5)
#tb = Time.now
#p first_k.inspect
#p tb - ta


#check the movie_rating_average(movie) method
#aver = movies_data.movie_rating_average(203)
#p aver


################
# check the MovieTest class
test_data = MovieTest.new(10)

# check the cal_mean_error
#mean = test_data.cal_mean_error
#p mean

#check the stddev method
#std = test_data.stddev
#p std

# check the cal_rms method
#rms = test_data.cal_rms
#p rms

# check to_s method
#tup = test_data.to_a
#p tup
