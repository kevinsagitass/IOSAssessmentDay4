//
//  ViewModel.swift
//  Day4
//
//  Created by P090MMCTSE011 on 19/10/23.
//

import Foundation
import UIKit
import CoreData

class ViewModel: NSObject {
    
    private(set) var pokemons: [PokemonModel] = [] {
        didSet {
            self.bindDataToVC()
        }
    }
    
    var bindDataToVC: () -> () = {}
    
    func getPokemon(
        onError: @escaping (Error) -> Void
    ) {
        var pokemonsResult: [PokemonModel] = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
                entityName: "Pokemon"
        )
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            result.forEach{pokemon in
                pokemonsResult.append(
                    PokemonModel(
                        id: pokemon.value(forKey: "id") as! Int64,
                        power: pokemon.value(forKey: "power") as! Int64,
                        name: pokemon.value(forKey: "name") as! String,
                        type: pokemon.value(forKey: "type") as! String
                    )
                )
            }
        } catch let err {
            onError(err)
        }
        
        self.pokemons = pokemonsResult
    }
    
    func createPokemon(name: String, type: String, power: Int64, onSuccess: @escaping () -> Void) {
        let id = UserDefaults.standard.integer(forKey: "id")
        UserDefaults.standard.setValue(id + 1, forKey: "id")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let pokemonEntity = NSEntityDescription.entity(forEntityName: "Pokemon", in: managedContext)
                
        let insert = NSManagedObject(
            entity: pokemonEntity!,
            insertInto: managedContext
        )
        insert.setValue(id, forKey: "id")
        insert.setValue(name, forKey: "name")
        insert.setValue(type, forKey: "type")
        insert.setValue(power, forKey: "power")
        
        do {
            try managedContext.save()
            
            onSuccess()
        } catch let err {
            print("Error in Save \(err)")
        }
    }

    func updatePokemon(id: Int64, name: String, type: String, power: Int64, onSuccess: @escaping () -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Pokemon")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let fetch = try managedContext.fetch(fetchRequest)
            let dataToUpdate = fetch[0] as! NSManagedObject
            
            dataToUpdate.setValue(name, forKey: "name")
            dataToUpdate.setValue(type, forKey: "type")
            dataToUpdate.setValue(power, forKey: "power")
            
            try managedContext.save()
            
            onSuccess()
        } catch let err {
            print ("Error Update \(err)")
        }
    }
    
    func deletePokemon(index: IndexPath, onSuccess: @escaping () -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Pokemon")
        fetchRequest.predicate = NSPredicate(format: "name = %@", self.pokemons[index.row].name)
        
        do {
            let dataToDelete = try managedContext.fetch(fetchRequest)[0] as! NSManagedObject
            managedContext.delete(dataToDelete)
            
            try managedContext.save()
            
            onSuccess()
        } catch let err {
            print("Error in Delete \(err)")
        }

    }
    
    func deleteAll() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
                entityName: "Pokemon"
        )
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            result.forEach{pokemon in
                managedContext.delete(pokemon)
            }
        } catch let err {
            print("Error in Delete All \(err)")
        }
    }
    
    func getAddModal(
        onError: @escaping (Error) -> Void,
        onSuccess: @escaping (UIAlertController) -> Void,
        onFailed: @escaping (UIAlertController) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: "New Pokemon", message: "Please Fill the Form", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {tf in tf.placeholder = "Name"})
        alert.addTextField(configurationHandler: {tf in tf.placeholder = "Type"})
        alert.addTextField(configurationHandler: {tf in
            tf.placeholder = "Power"
            tf.keyboardType = .numberPad
        })
        
        alert.addAction(UIAlertAction(title: "Add Pokemon", style: .default, handler: {
            action in
            
            if alert.textFields![0].text!.isEmpty || alert.textFields![1].text!.isEmpty {
                let warning = UIAlertController(title: "Warning", message: "Value Cannot be Empty", preferredStyle: .alert)
                warning.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                
                onFailed(warning)
            } else {
                let success = UIAlertController(title: "Success", message: "Pokemon Created", preferredStyle: .alert)
                success.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                
                self.createPokemon(name: alert.textFields![0].text!, type: alert.textFields![1].text!, power: Int64(alert.textFields![2].text!) ?? 0) {
                    self.getPokemon(onError: onError)
                }
                
                onSuccess(success)
            }
        }))
        
        return alert
    }
    
    func getEditModal(
        index: Int,
        onError: @escaping (Error) -> Void,
        onSuccess: @escaping (UIAlertController) -> Void,
        onFailed: @escaping (UIAlertController) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: "Edit Pokemon", message: "Please Fill the Form", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {tf in
            tf.placeholder = "Name"
            tf.text = self.pokemons[index].name
        })
        alert.addTextField(configurationHandler: {tf in
            tf.placeholder = "Type"
            tf.text = self.pokemons[index].type
        })
        alert.addTextField(configurationHandler: {tf in
            tf.placeholder = "Power"
            tf.text = "\(self.pokemons[index].power)"
            tf.keyboardType = .numberPad
        })
        
        alert.addAction(UIAlertAction(title: "Edit Pokemon", style: .default, handler: {
            action in
            
            if alert.textFields![0].text!.isEmpty || alert.textFields![1].text!.isEmpty {
                let warning = UIAlertController(title: "Warning", message: "Value Cannot be Empty", preferredStyle: .alert)
                warning.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                onFailed(warning)
            } else {
                self.updatePokemon(id: self.pokemons[index].id, name: alert.textFields![0].text!, type: alert.textFields![1].text!, power: Int64( alert.textFields![2].text!) ?? 0) {
                    self.getPokemon(onError: onError)
                }
                
                let success = UIAlertController(title: "Success", message: "Pokemon Edited", preferredStyle: .alert)
                success.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                onSuccess(success)
            }
        }))
        
        return alert
    }
}
