//
//  HomePresenter.swift
//  VeryCreatives-Task
//
//  Created by Noor Walid on 13/04/2022.
//

import Foundation

protocol HomePresenterProtocol {
    var popularMoviesList: MovieResponse? { get }
    var topRatedMoviesList: MovieResponse? { get }
    var userMoviePreference: MovieType { get set }
    
    func fetchPopularMovies(page: Int)
    func fetchTopRatedMovies(page: Int)
    func navigateToMovie(at index: Int)
}

class HomePresenter: HomePresenterProtocol {
    var popularMoviesList: MovieResponse?
    var topRatedMoviesList: MovieResponse?
    var userMoviePreference: MovieType = .topRated
    
    private let DatabaseManager : DatabaseProtocol
    weak var homeView: HomeViewControllerProtocol?
    
    init(DatabaseManager: DatabaseProtocol = CoreDataManager(modelName: Constants.CoreDataModelFile), homeView: HomeViewControllerProtocol) {
        self.DatabaseManager = DatabaseManager
        self.homeView = homeView
    }
    
    func fetchPopularMovies(page: Int = 1) {
        NetworkManager.shared.fetchMovies(page: page, type: MovieType.popular) {[weak self] (movies: MovieResponse?, error: Error?) in
            if error != nil {
                print("There was an error fetching data in presenter. Error: \(error!.localizedDescription)")
            }
            
            if self?.popularMoviesList == nil {
                guard let moviesArray = movies?.results else { return }
                self?.popularMoviesList = movies
                NetworkRepository.shared.fetchedMovies += moviesArray
            } else {
                guard let moreMovies = movies?.results else { return }
                self?.popularMoviesList?.results! += moreMovies
                NetworkRepository.shared.fetchedMovies += moreMovies
            }
            
            
            DispatchQueue.main.async {
                self?.homeView?.reloadData()
            }
        }
    }
    
    func fetchTopRatedMovies(page: Int = 1) {
        NetworkManager.shared.fetchMovies(page: page, type: MovieType.topRated) {[weak self] (movies: MovieResponse?, error: Error?) in
            if error != nil {
                print("There was an error fetching data in presenter. Error: \(error!.localizedDescription)")
            }
            
            if self?.topRatedMoviesList == nil {
                guard let moviesArray = movies?.results else { return }
                self?.topRatedMoviesList = movies
                NetworkRepository.shared.fetchedMovies += moviesArray
            } else {
                guard let moreMovies = movies?.results else { return }
                self?.topRatedMoviesList?.results! += moreMovies
                NetworkRepository.shared.fetchedMovies += moreMovies
            }
            
            DispatchQueue.main.async {
                self?.homeView?.reloadData()
            }
        }
    }
    
    func navigateToMovie(at index: Int) {
        switch userMoviePreference {
        case .topRated:
            guard let movie = topRatedMoviesList?.results?[index] else { return }
            let movieModel = convertResponseToModel(movie: movie)
            if let _ = movieModel {
                movie.movieState = .favorited
                let route = HomeNavigationRoutes.MovieDetails(movie)
                homeView?.navigate(to: route)
            } else {
                let route = HomeNavigationRoutes.MovieDetails(movie)
                homeView?.navigate(to: route)
            }
            
        case .popular:
            guard let movie = popularMoviesList?.results?[index] else { return }
            let movieModel = convertResponseToModel(movie: movie)
            if let _ = movieModel {
                movie.movieState = .favorited
                let route = HomeNavigationRoutes.MovieDetails(movie)
                homeView?.navigate(to: route)
            } else {
                let route = HomeNavigationRoutes.MovieDetails(movie)
                homeView?.navigate(to: route)
            }
        }
        
    }
    
    private func convertModelToResponse(model: MovieDataManagedObject) -> MovieData? {
        for movie in NetworkRepository.shared.fetchedMovies {
            if model.id == movie.id ?? 0 {
                return movie
            }
        }
        
        return nil
        
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
