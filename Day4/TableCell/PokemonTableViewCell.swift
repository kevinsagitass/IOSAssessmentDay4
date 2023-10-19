//
//  PokemonTableViewCell.swift
//  Day4
//
//  Created by P090MMCTSE011 on 19/10/23.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setValue(pokemon: PokemonModel) {
        self.nameLabel.text = pokemon.name
        self.typeLabel.text = pokemon.type
        self.powerLabel.text = String(pokemon.power)
    }
    
}
