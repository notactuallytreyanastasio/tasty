# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tasty.Repo.insert!(%Tasty.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Tasty.Accounts
alias Tasty.Bookmarks
alias Tasty.Repo

IO.puts("🌱 Starting database seeding...")

# Create a test user (or get existing one)
user = case Accounts.register_user(%{
  email: "reddit@example.com",
  username: "redditcurator",
  password: "testpassword123",
  bio: "Curator of interesting Reddit content"
}) do
  {:ok, user} -> user
  {:error, _} -> 
    # User already exists, fetch it
    Tasty.Repo.get_by!(Tasty.Accounts.User, username: "redditcurator")
end

IO.puts("✅ Created test user: #{user.username}")

# Create tags for different Reddit communities and topics
tags_data = [
  %{name: "Programming", slug: "programming", color: "#3B82F6"},
  %{name: "Technology", slug: "technology", color: "#10B981"},
  %{name: "Science", slug: "science", color: "#8B5CF6"},
  %{name: "Gaming", slug: "gaming", color: "#EF4444"},
  %{name: "News", slug: "news", color: "#F59E0B"},
  %{name: "Funny", slug: "funny", color: "#EC4899"},
  %{name: "AskReddit", slug: "askreddit", color: "#6B7280"},
  %{name: "TIL", slug: "til", color: "#14B8A6"},
  %{name: "Showerthoughts", slug: "showerthoughts", color: "#F97316"},
  %{name: "DIY", slug: "diy", color: "#84CC16"},
  %{name: "Cooking", slug: "cooking", color: "#F43F5E"},
  %{name: "Photography", slug: "photography", color: "#8B5CF6"}
]

IO.puts("📂 Creating tags...")
created_tags = Enum.map(tags_data, fn tag_data ->
  case Bookmarks.create_tag(tag_data) do
    {:ok, tag} -> 
      IO.puts("   Created tag: #{tag.name}")
      tag
    {:error, _} ->
      # Tag already exists, fetch it
      existing_tag = Repo.get_by!(Tasty.Bookmarks.Tag, slug: tag_data.slug)
      IO.puts("   Found existing tag: #{existing_tag.name}")
      existing_tag
  end
end)

# 100 Reddit-style bookmarks with realistic data
reddit_bookmarks = [
  %{title: "How to learn programming from scratch", url: "https://reddit.com/r/programming/post1", description: "A comprehensive guide for beginners starting their programming journey", tags: ["Programming"]},
  %{title: "The future of AI and machine learning", url: "https://news.ycombinator.com/item?id=12345", description: "Discussion about where AI technology is heading in the next decade", tags: ["Technology", "Science"]},
  %{title: "Scientists discover new exoplanet", url: "https://github.com/astronomy/exoplanet-discovery", description: "Astronomers find potentially habitable planet 40 light years away", tags: ["Science", "News"]},
  %{title: "Best indie games of 2024", url: "https://reddit.com/r/gaming/post4", description: "Community recommendations for hidden gem indie games", tags: ["Gaming"]},
  %{title: "Climate change effects on ocean currents", url: "https://medium.com/@scientist/ocean-currents-climate", description: "New research shows how warming affects global ocean circulation", tags: ["Science", "News"]},
  %{title: "Why do cats purr?", url: "https://stackoverflow.com/questions/12345/cat-purring", description: "The science behind feline purring behavior", tags: ["AskReddit", "Science"]},
  %{title: "TIL octopuses have three hearts", url: "https://youtube.com/watch?v=octopus123", description: "Fascinating facts about octopus anatomy", tags: ["TIL", "Science"]},
  %{title: "Shower thought: We never see our own face", url: "https://twitter.com/user/status/123456", description: "Only reflections and photos, never our actual face", tags: ["Showerthoughts"]},
  %{title: "Built a treehouse for my kids", url: "https://pinboard.in/u:user/b:treehouse", description: "6-month project finally complete with photos", tags: ["DIY"]},
  %{title: "Perfect sourdough bread recipe", url: "https://reddit.com/r/cooking/post10", description: "After 50 attempts, I finally nailed it", tags: ["Cooking", "DIY"]},
  
  %{title: "JavaScript vs TypeScript: When to use what", url: "https://reddit.com/r/programming/post11", description: "Practical advice for choosing the right tool", tags: ["Programming", "Technology"]},
  %{title: "Quantum computing breakthrough", url: "https://reddit.com/r/technology/post12", description: "Google claims quantum supremacy with new chip", tags: ["Technology", "Science", "News"]},
  %{title: "Mars rover finds evidence of ancient water", url: "https://reddit.com/r/science/post13", description: "Perseverance discovers mineral formations suggesting past water activity", tags: ["Science", "News"]},
  %{title: "Top 10 couch co-op games", url: "https://reddit.com/r/gaming/post14", description: "Best games to play with friends locally", tags: ["Gaming"]},
  %{title: "What's the weirdest thing you believed as a kid?", url: "https://reddit.com/r/askreddit/post15", description: "Hilarious childhood misconceptions shared by users", tags: ["AskReddit", "Funny"]},
  %{title: "TIL honey never spoils", url: "https://reddit.com/r/todayilearned/post16", description: "Archaeologists found edible honey in Egyptian tombs", tags: ["TIL", "Science"]},
  %{title: "We're all just brains piloting bone mechs", url: "https://reddit.com/r/showerthoughts/post17", description: "Weird way to think about human anatomy", tags: ["Showerthoughts"]},
  %{title: "Restored a 1960s motorcycle", url: "https://reddit.com/r/diy/post18", description: "Before and after photos of my Triumph restoration", tags: ["DIY"]},
  %{title: "Homemade ramen that rivals restaurants", url: "https://reddit.com/r/cooking/post19", description: "24-hour broth recipe and technique", tags: ["Cooking"]},
  %{title: "Long exposure photography tips", url: "https://reddit.com/r/photography/post20", description: "How to capture stunning night sky photos", tags: ["Photography"]},
  
  %{title: "Learning Rust after 10 years of Python", url: "https://reddit.com/r/programming/post21", description: "My experience switching to systems programming", tags: ["Programming"]},
  %{title: "5G rollout update across major cities", url: "https://reddit.com/r/technology/post22", description: "Current state of 5G infrastructure deployment", tags: ["Technology", "News"]},
  %{title: "New CRISPR technique treats genetic diseases", url: "https://reddit.com/r/science/post23", description: "Gene editing breakthrough offers hope for rare conditions", tags: ["Science", "News"]},
  %{title: "Retro gaming setup showcase", url: "https://reddit.com/r/gaming/post24", description: "My collection of vintage consoles and CRT setup", tags: ["Gaming"]},
  %{title: "What skill would you download Matrix-style?", url: "https://reddit.com/r/askreddit/post25", description: "If you could instantly learn any skill", tags: ["AskReddit"]},
  %{title: "TIL bananas are berries but strawberries aren't", url: "https://reddit.com/r/todayilearned/post26", description: "Botanical classification is confusing", tags: ["TIL", "Science"]},
  %{title: "Your name backwards is your demon name", url: "https://reddit.com/r/showerthoughts/post27", description: "Mine would be really hard to pronounce", tags: ["Showerthoughts", "Funny"]},
  %{title: "Built a smart mirror with Raspberry Pi", url: "https://reddit.com/r/diy/post28", description: "Weather, calendar, and news display", tags: ["DIY", "Technology"]},
  %{title: "Fermentation experiments: kimchi and kombucha", url: "https://reddit.com/r/cooking/post29", description: "My journey into fermented foods", tags: ["Cooking", "DIY"]},
  %{title: "Urban wildlife photography tips", url: "https://reddit.com/r/photography/post30", description: "Capturing nature in the city", tags: ["Photography"]},
  
  %{title: "Docker vs Kubernetes: Beginner's guide", url: "https://reddit.com/r/programming/post31", description: "Understanding containerization and orchestration", tags: ["Programming", "Technology"]},
  %{title: "Apple announces new MacBook with M4 chip", url: "https://reddit.com/r/technology/post32", description: "Performance benchmarks and feature comparison", tags: ["Technology", "News"]},
  %{title: "Fusion reactor achieves net energy gain", url: "https://reddit.com/r/science/post33", description: "Historic milestone in clean energy research", tags: ["Science", "News"]},
  %{title: "Speedrunning community breaks another record", url: "https://reddit.com/r/gaming/post34", description: "Super Mario 64 120-star world record broken by 0.1 seconds", tags: ["Gaming", "News"]},
  %{title: "Teachers of Reddit: What's your 'aha' moment?", url: "https://reddit.com/r/askreddit/post35", description: "Stories of breakthrough moments in education", tags: ["AskReddit"]},
  %{title: "TIL sharks are older than trees", url: "https://reddit.com/r/todayilearned/post36", description: "Sharks have existed for 400 million years", tags: ["TIL", "Science"]},
  %{title: "We put milk in a fridge but cookies in a jar", url: "https://reddit.com/r/showerthoughts/post37", description: "Random food storage observations", tags: ["Showerthoughts"]},
  %{title: "Automated garden watering system", url: "https://reddit.com/r/diy/post38", description: "Arduino-based plant care with sensors", tags: ["DIY", "Technology"]},
  %{title: "French cooking techniques every chef should know", url: "https://reddit.com/r/cooking/post39", description: "Classic methods that improve any dish", tags: ["Cooking"]},
  %{title: "Macro photography on a budget", url: "https://reddit.com/r/photography/post40", description: "Getting close-up shots without expensive gear", tags: ["Photography"]},
  
  %{title: "Web3 and blockchain: Hype or future?", url: "https://reddit.com/r/programming/post41", description: "Critical analysis of decentralized web technologies", tags: ["Programming", "Technology"]},
  %{title: "Tesla's new Autopilot update", url: "https://reddit.com/r/technology/post42", description: "Full self-driving capabilities and safety concerns", tags: ["Technology", "News"]},
  %{title: "Ocean microplastics reach alarming levels", url: "https://reddit.com/r/science/post43", description: "Study reveals widespread plastic pollution impact", tags: ["Science", "News"]},
  %{title: "Indie game developer success story", url: "https://reddit.com/r/gaming/post44", description: "From bedroom coder to million-dollar game", tags: ["Gaming", "Programming"]},
  %{title: "What conspiracy theory turned out to be true?", url: "https://reddit.com/r/askreddit/post45", description: "Historical events that seemed unbelievable", tags: ["AskReddit", "News"]},
  %{title: "TIL penguins have knees", url: "https://reddit.com/r/todayilearned/post46", description: "They're just hidden inside their bodies", tags: ["TIL", "Science"]},
  %{title: "Socks disappear in the dryer to another dimension", url: "https://reddit.com/r/showerthoughts/post47", description: "The only logical explanation", tags: ["Showerthoughts", "Funny"]},
  %{title: "Home automation with smart switches", url: "https://reddit.com/r/diy/post48", description: "Retrofitting old house with modern tech", tags: ["DIY", "Technology"]},
  %{title: "Plant-based meat alternatives taste test", url: "https://reddit.com/r/cooking/post49", description: "Blind comparison of Beyond, Impossible, and others", tags: ["Cooking", "Science"]},
  %{title: "Night sky astrophotography guide", url: "https://reddit.com/r/photography/post50", description: "Capturing the Milky Way and deep space objects", tags: ["Photography", "Science"]},
  
  %{title: "Machine learning model deployment best practices", url: "https://reddit.com/r/programming/post51", description: "From training to production: lessons learned", tags: ["Programming", "Technology"]},
  %{title: "Smartphone battery technology breakthrough", url: "https://reddit.com/r/technology/post52", description: "New lithium-sulfur batteries promise week-long charge", tags: ["Technology", "Science"]},
  %{title: "Antarctic ice sheet collapse timeline", url: "https://reddit.com/r/science/post53", description: "Climate models predict faster melting than expected", tags: ["Science", "News"]},
  %{title: "E-sports prize pools reach new heights", url: "https://reddit.com/r/gaming/post54", description: "Professional gaming now rivals traditional sports", tags: ["Gaming", "News"]},
  %{title: "What's your most irrational fear?", url: "https://reddit.com/r/askreddit/post55", description: "Phobias that don't make logical sense", tags: ["AskReddit"]},
  %{title: "TIL bubble wrap was invented for wallpaper", url: "https://reddit.com/r/todayilearned/post56", description: "Original purpose was very different", tags: ["TIL"]},
  %{title: "Every pizza is a personal pizza if you believe", url: "https://reddit.com/r/showerthoughts/post57", description: "Motivational food philosophy", tags: ["Showerthoughts", "Funny"]},
  %{title: "3D printed prosthetic hand for my son", url: "https://reddit.com/r/diy/post58", description: "Open-source design helps kids worldwide", tags: ["DIY", "Technology"]},
  %{title: "Molecular gastronomy experiments at home", url: "https://reddit.com/r/cooking/post59", description: "Spherification and foam techniques", tags: ["Cooking", "Science"]},
  %{title: "Street photography ethics and tips", url: "https://reddit.com/r/photography/post60", description: "Capturing candid moments respectfully", tags: ["Photography"]},
  
  %{title: "Functional programming concepts in JavaScript", url: "https://reddit.com/r/programming/post61", description: "Map, reduce, and immutability explained", tags: ["Programming"]},
  %{title: "Renewable energy hits 30% of global power", url: "https://reddit.com/r/technology/post62", description: "Solar and wind adoption accelerating worldwide", tags: ["Technology", "Science", "News"]},
  %{title: "JWST discovers oldest galaxy ever observed", url: "https://reddit.com/r/science/post63", description: "Galaxy formed just 400 million years after Big Bang", tags: ["Science", "News"]},
  %{title: "VR gaming setup recommendations", url: "https://reddit.com/r/gaming/post64", description: "Best headsets and accessories for immersive gaming", tags: ["Gaming", "Technology"]},
  %{title: "What smell instantly transports you to childhood?", url: "https://reddit.com/r/askreddit/post65", description: "Nostalgic scents and their powerful memories", tags: ["AskReddit"]},
  %{title: "TIL cashews grow on the outside of fruits", url: "https://reddit.com/r/todayilearned/post66", description: "Cashew apples are eaten in many countries", tags: ["TIL", "Science"]},
  %{title: "Fish probably think we can fly", url: "https://reddit.com/r/showerthoughts/post67", description: "Different perspectives on mobility", tags: ["Showerthoughts"]},
  %{title: "Solar panel installation on my tiny house", url: "https://reddit.com/r/diy/post68", description: "Off-grid living setup and lessons learned", tags: ["DIY", "Technology"]},
  %{title: "Sourdough starter from 1889 still alive", url: "https://reddit.com/r/cooking/post69", description: "Family heirloom culture produces amazing bread", tags: ["Cooking"]},
  %{title: "Portrait photography with natural light", url: "https://reddit.com/r/photography/post70", description: "No flash needed for stunning portraits", tags: ["Photography"]},
  
  %{title: "API design principles for scalable systems", url: "https://reddit.com/r/programming/post71", description: "REST, GraphQL, and gRPC comparison", tags: ["Programming", "Technology"]},
  %{title: "Brain-computer interface trials show promise", url: "https://reddit.com/r/technology/post72", description: "Paralyzed patients control devices with thoughts", tags: ["Technology", "Science"]},
  %{title: "Coral reef restoration using 3D printing", url: "https://reddit.com/r/science/post73", description: "Artificial structures help coral growth", tags: ["Science", "Technology"]},
  %{title: "Gaming chair vs office chair debate", url: "https://reddit.com/r/gaming/post74", description: "Ergonomics and comfort for long sessions", tags: ["Gaming"]},
  %{title: "What's a skill that seems magical but is easy?", url: "https://reddit.com/r/askreddit/post75", description: "Impressive abilities that anyone can learn", tags: ["AskReddit"]},
  %{title: "TIL humans share 60% of DNA with bananas", url: "https://reddit.com/r/todayilearned/post76", description: "Common evolutionary ancestry surprises", tags: ["TIL", "Science"]},
  %{title: "Restaurants are live cooking shows with food", url: "https://reddit.com/r/showerthoughts/post77", description: "Entertainment value of dining out", tags: ["Showerthoughts"]},
  %{title: "Murphy bed with hidden desk combo", url: "https://reddit.com/r/diy/post78", description: "Space-saving furniture for small apartments", tags: ["DIY"]},
  %{title: "Umami: The fifth taste explained", url: "https://reddit.com/r/cooking/post79", description: "Science behind savory flavors", tags: ["Cooking", "Science"]},
  %{title: "Drone photography regulations and tips", url: "https://reddit.com/r/photography/post80", description: "Legal requirements and creative techniques", tags: ["Photography", "Technology"]},
  
  %{title: "Microservices vs monolith: When to choose what", url: "https://reddit.com/r/programming/post81", description: "Architecture decisions for different scales", tags: ["Programming", "Technology"]},
  %{title: "Quantum internet prototype successfully tested", url: "https://reddit.com/r/technology/post82", description: "Unhackable communication network demonstrated", tags: ["Technology", "Science"]},
  %{title: "Extinct species brought back with gene editing", url: "https://reddit.com/r/science/post83", description: "De-extinction project shows early success", tags: ["Science", "News"]},
  %{title: "Board games making a comeback", url: "https://reddit.com/r/gaming/post84", description: "Analog gaming thrives in digital age", tags: ["Gaming"]},
  %{title: "What's the most useless superpower you can think of?", url: "https://reddit.com/r/askreddit/post85", description: "Hilariously impractical abilities", tags: ["AskReddit", "Funny"]},
  %{title: "TIL wombat poop is cube-shaped", url: "https://reddit.com/r/todayilearned/post86", description: "Unique digestive system creates geometric waste", tags: ["TIL", "Science"]},
  %{title: "The internet is just fancy rocks thinking", url: "https://reddit.com/r/showerthoughts/post87", description: "Silicon-based computation philosophy", tags: ["Showerthoughts", "Technology"]},
  %{title: "Greenhouse built from recycled windows", url: "https://reddit.com/r/diy/post88", description: "Sustainable gardening structure project", tags: ["DIY"]},
  %{title: "Ancient grains and their modern uses", url: "https://reddit.com/r/cooking/post89", description: "Quinoa, amaranth, and forgotten nutrition", tags: ["Cooking"]},
  %{title: "Time-lapse photography techniques", url: "https://reddit.com/r/photography/post90", description: "Capturing change over hours and days", tags: ["Photography"]},
  
  %{title: "Database indexing strategies for performance", url: "https://reddit.com/r/programming/post91", description: "When and how to optimize query speed", tags: ["Programming", "Technology"]},
  %{title: "Robotic surgery reaches new precision levels", url: "https://reddit.com/r/technology/post92", description: "AI-assisted operations improve outcomes", tags: ["Technology", "Science"]},
  %{title: "Plastic-eating enzymes could solve pollution", url: "https://reddit.com/r/science/post93", description: "Engineered bacteria break down waste", tags: ["Science", "Technology"]},
  %{title: "Gaming addiction awareness and prevention", url: "https://reddit.com/r/gaming/post94", description: "Healthy gaming habits and warning signs", tags: ["Gaming"]},
  %{title: "What's the weirdest compliment you've received?", url: "https://reddit.com/r/askreddit/post95", description: "Unusual but heartwarming praise", tags: ["AskReddit", "Funny"]},
  %{title: "TIL flamingos are pink from eating shrimp", url: "https://reddit.com/r/todayilearned/post96", description: "Diet determines their vibrant color", tags: ["TIL", "Science"]},
  %{title: "Elevators are just rooms that move between floors", url: "https://reddit.com/r/showerthoughts/post97", description: "Perspective on vertical transportation", tags: ["Showerthoughts"]},
  %{title: "Hidden bookshelf door to secret room", url: "https://reddit.com/r/diy/post98", description: "Childhood dream finally realized", tags: ["DIY"]},
  %{title: "Fermented foods and gut health connection", url: "https://reddit.com/r/cooking/post99", description: "Science behind probiotics and wellness", tags: ["Cooking", "Science"]},
  %{title: "Light painting photography tutorial", url: "https://reddit.com/r/photography/post100", description: "Creating art with long exposures and LEDs", tags: ["Photography"]}
]

# Check if bookmarks already exist
existing_count = Repo.aggregate(Tasty.Bookmarks.Bookmark, :count, :id)

if existing_count > 10 do
  IO.puts("📚 Database already has #{existing_count} bookmarks, skipping seeding...")
else
  IO.puts("📚 Creating 100 Reddit-style bookmarks...")
  
  # Create bookmarks with tags
  Enum.with_index(reddit_bookmarks, 1) |> Enum.each(fn {bookmark_data, index} ->
    # Create the bookmark
    case Bookmarks.create_bookmark(%{
      url: bookmark_data.url,
      title: bookmark_data.title,
      description: bookmark_data.description,
      user_id: user.id,
      is_public: true,
      view_count: Enum.random(0..1000),
      favicon_url: "https://reddit.com/favicon.ico"
    }) do
      {:ok, bookmark} ->
        # Add tags to the bookmark
        bookmark_data.tags |> Enum.each(fn tag_name ->
          tag = Enum.find(created_tags, &(&1.name == tag_name))
          if tag do
            # Create the many-to-many association (ignore duplicates)
            Repo.query("INSERT INTO bookmark_tags (bookmark_id, tag_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", [bookmark.id, tag.id])
          end
        end)
        
      {:error, _} ->
        # Bookmark already exists, skip
        nil
    end
    
    if rem(index, 10) == 0 do
      IO.puts("   Processed #{index}/100 bookmarks...")
    end
  end)
end

IO.puts("✅ Successfully seeded database with:")
IO.puts("   - 1 test user")
IO.puts("   - #{length(created_tags)} tags")
IO.puts("   - 100 Reddit-style bookmarks")
IO.puts("   - Tag associations for filtering")
IO.puts("")
IO.puts("🚀 Ready to browse public bookmarks with LiveView!")
