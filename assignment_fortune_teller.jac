import random;
import from byllm.llm { Model };

glob llm = Model(model_name="gpt-4o-mini");

"""Create a short, mystical fortune for {name} who feels {mood}. Category: {category}. Keep it under 50 words, fun and positive."""

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
    if not self.name {
        print("Welcome to the Fortune Teller! Please enter your name:");
        self.name = input("> ");
    }
    if not self.mood {
        print(f"Hello {self.name}! How are you feeling today?");
        self.mood = input("> ");
    }
    print(f"\nGreat! Let's see what the stars have in store for you, {self.name} who feels {self.mood}.\n");
    create_fortune_path();
}


prev = root;
for i in range(3) {
    cat = self.categories[i % len(self.categories)];
    next_node = prev ++> fortune_reading(
        category=cat,
        name=self.name,
        mood=self.mood
    );
    prev = next_node;
}

for node in std.out(root --> (`?fortune_reading)) {
    node.fortune = generate_fortune(node.category, node.name, node.mood);
    print(f"\n🔮 A fortune about {node.category} is ready!");
}

first = std.out(root --> (`?fortune_reading))[0];
self.reading_count = 1;
visit first;
fire here read_fortune;

self.reading_count += 1;

if self.reading_count < 3 {
    # Traverse to next node
    next_node = std.out(here --> (`?fortune_reading))[0];
    visit next_node;
    fire here read_fortune;
} else {
    print(f"\n✨ The stars have spoken—three fortunes revealed! Thanks for playing, {self.name}.");
    disengage;
}
}
