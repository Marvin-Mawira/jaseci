import random;
import from byllm.llm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

def generate_fortune(category: str, name: str, mood: str) -> str by llm();

node fortune_reading {
    has category: str;
    has name: str;
    has mood: str;
    has fortune: str;
}

walker FortuneTeller {
    has name: str;
    has mood: str;
    has categories: list = ["love", "career", "adventure"];
    
    # can start with `root entry`;
    # can read_fortune with `fortune_reading entry`;
}

# with entry {
#     spawn here walker::FortuneTeller(name="", mood="");
# }

impl FortuneTeller.start {
    # Get user input
    if not self.name {
        print("Welcome to the Fortune Teller! Please enter your name:");
        self.name = input("> ");
    }
    if not self.mood {
        print(f"Hello {self.name}! How are you feeling today?");
        self.mood = input("> ");
    }
    
    print(f"\nGreat! Let's see what the stars have in store for you, {self.name} who feels {self.mood}.\n");
    
    # Create fortune nodes for each category
    for category in self.categories {
        spawn here ++> fortune_reading(
            category=category,
            name=self.name, 
            mood=self.mood
        );
    }
    
    # Visit first fortune node
    # first_fortune = [here --> (`?fortune_reading`)][0];
    # visit first_fortune;
}

impl FortuneTeller.read_fortune {
    # Generate fortune if not already generated
    if not here.fortune {
        here.fortune = generate_fortune(here.category, here.name, here.mood);
        print(f"\n🔮 Generating your {here.category} fortune...");
    }
    
    # Display the fortune
    print(f"\n🌟 {here.category.upper()} FORTUNE:");
    print(here.fortune);
    
    # Check if there are more fortunes to read
    # next_fortunes = [here --> (`?fortune_reading`)];
    if next_fortunes {
        visit next_fortunes[0];
    } else {
        print(f"\n✨ All fortunes revealed! Thanks for playing, {self.name}.");
        disengage;
    }
}