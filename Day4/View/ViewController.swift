//
//  ViewController.swift
//  Day4
//
//  Created by P090MMCTSE011 on 19/10/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pokemonTable: UITableView!
    
    var viewModel: ViewModel!
    var onErrorGetPokemon: (Error) -> Void = {err in
        print("Error in get \(err)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonTable.register(UINib(
            nibName: "PokemonTableViewCell",
            bundle: nil
        ), forCellReuseIdentifier: "pokemonTableCell")
        
        pokemonTable.delegate = self
        pokemonTable.dataSource = self
        
        viewModel = ViewModel()
//        viewModel.deleteAll()
        viewModel.bindDataToVC = {
            self.pokemonTable.reloadData()
        }
        viewModel.getPokemon(onError: onErrorGetPokemon)
    }
    
    @IBAction func addBtnClick(_ sender: Any) {
        
        let alert = self.viewModel.getAddModal(onError: onErrorGetPokemon) { success in
            self.present(success, animated: true)
        } onFailed: { warning in
            self.present(warning, animated: true)
        }
        
        self.present(alert, animated: true)
    }
    
    func editPokemon(index: Int) {
        let alert = self.viewModel.getEditModal(index: index, onError: onErrorGetPokemon) { success in
            self.present(success, animated: true)
        } onFailed: { warning in
            self.present(warning, animated: true)
        }
        
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonTableCell", for: indexPath) as! PokemonTableViewCell
        cell.setValue(pokemon: self.viewModel.pokemons[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.editPokemon(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.viewModel.deletePokemon(index: indexPath) {
                self.viewModel.getPokemon(onError: self.onErrorGetPokemon)
            }
        }
    }

}

