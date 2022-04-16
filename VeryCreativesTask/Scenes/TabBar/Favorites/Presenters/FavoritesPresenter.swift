//
//  FavoritesPresenter.swift
//  VeryCreatives-Task
//
//  Created by Noor Walid on 14/04/2022.
//

import Foundation

protocol FavoritesPresenterProtocol {
    var favoritedMovies: [MovieDataManagedObject]? { get }
    
    func fetchFavoriteMovies()
    func saveMovieAsFavorite(movie: MovieDataManagedObject)
    func deleteMovieFromFavorites(movie: MovieDataManagedObject)
    func navigateToMovie(at index: Int)
}

class FavoritesPresenter: FavoritesPresenterProtocol {
    
    var favoritedMovies: [MovieDataManagedObject]?
    weak var favoritesView: FavoritesViewControllerProtocol?
    private var DatabaseManager : DatabaseProtocol
    
    init(DatabaseManager: DatabaseProtocol = CoreDataManager(modelName: Constants.CoreDataModelFile), favoritesView: FavoritesViewControllerProtocol) {
        self.favoritesView = favoritesView
        self.DatabaseManager = DatabaseManager
    }
    
    func fetchFavoriteMovies() {
        favoritedMovies = DatabaseManager.fetch()
        favoritesView?.reloadData()
    }
    
    func navigateToMovie(at index: Int) {
        guard let model = favoritedMovies?[index] else { return }
        let movie = convertModelToResponse(model: model)
        let route = FavoritesNavigationRoutes.MovieDetails(movie)
        favoritesView?.navigate(to: route)
    }
    
    func saveMovieAsFavorite(movie: MovieDataManagedObject) {
        let movie = convertModelToResponse(model: movie)
        DatabaseManager.save(movie: movie)
    }
    
    func deleteMovieFromFavorites(movie: MovieDataManagedObject) {
        let movie = convertModelToResponse(model: movie)
        DatabaseManager.delete(movie: movie)
        favoritesView?.reloadData()
    }
    
    private func convertModelToResponse(model: MovieDataManagedObject) -> MovieData {
        for movie in NetworkRepository.shared.fetchedMovies {
            if model.id == movie.id ?? 0 {
                return movie
            }
        }
        return MovieData()
    }
    
    private func convertResponseToModel(movie: MovieData) -> MovieDataManagedObject? {
        let favMovieModels = DatabaseManager.fetch()
        guard let movieID = movie.id else { return nil }
        for movieModel in favMovieModels {
            if movieModel.id == Int32(movieID) {
                return movieModel
            }
        }
        
        return nil
    }
    
    
}
