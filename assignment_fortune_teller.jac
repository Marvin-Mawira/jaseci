import random;
import from byllm.llm { Model };

glob llm = Model(model_name="gpt-4o-mini");

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
    has reading_count: int = 0;
    has categories: list[str] = ["love", "career", "adventure"];
    
    impl FortuneTeller.start {
        if (!self.name) {
            print("Welcome to the Fortune Teller! Please enter your name:");
            self.name = input("> ");
        }
        if (!self.mood) {
            print(f"Hello {self.name}! How are you feeling today?");
            self.mood = input("> ");
        }
        print(f"\nGreat! Let's see what the stars have in store for you, {self.name} who feels {self.mood}.\n");
        
        # Create fortune nodes
        prev = root;
        for i in range(3) {
            cat = self.categories[i % std.length(self.categories)];
            next_node = prev ++> fortune_reading(
                category=cat,
                name=self.name,
                mood=self.mood
            );
            prev = next_node;
        }
        
        # Generate fortunes for all nodes
        for node in std.out(root --> (`?fortune_reading`)) {
            node.fortune = generate_fortune(node.category, node.name, node.mood);
            print(f"\n🔮 A fortune about {node.category} is ready!");
        }
        
        # Start reading fortunes
        first = std.out(root --> (`?fortune_reading`))[0];
        self.reading_count = 1;
        visit first with read_fortune;
    }
    
    impl read_fortune {
        print(f"\n🌟 {here.category.upper()} FORTUNE:");
        print(here.fortune);
        
        self.reading_count += 1;
        
        if (self.reading_count < 4) {
            # Get next node
            next_nodes = std.out(here --> (`?fortune_reading`));
            if (std.length(next_nodes) > 0) {
                next_node = next_nodes[0];
                visit next_node with read_fortune;
            }
        } else {
            print(f"\n✨ The stars have spoken—three fortunes revealed! Thanks for playing, {self.name}.");
            disengage;
        }
    }
}

# Initialize and run the walker
init {
    spawn here walker::FortuneTeller(name="", mood="");
}