

public class Stats {
    public int Constitution { get; set; } //HP
    public int Attack { get; set; }
    public int Defense { get; set; }
    public int Arcane { get; set; } //Magic Attack
    public int Warding; //Magic Defense
    public int Agility;
    public int Luck;


    public Stats(int con, int atk, int def, int arc, int ward, int agi, int luck) {
        this.Constitution = con;
        this.Attack = atk;
        this.Defense = def;
        this.Arcane = arc;
        this.Warding = ward;
        this.Agility = agi;
        this.Luck = luck;
    }
}