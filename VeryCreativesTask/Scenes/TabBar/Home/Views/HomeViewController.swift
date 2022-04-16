//
//  HomeViewController.swift
//  VeryCreatives-Task
//
//  Created by Noor Walid on 13/04/2022.
//

import UIKit

protocol HomeViewControllerProtocol: AnyObject, NavigationRoute {
    func reloadData()
}

@available(iOS 13.0, *)
class HomeViewController: UIViewController, HomeViewControllerProtocol {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var usernameLabel: UILabel!
    
    private var homePresenter: HomePresenterProtocol?
    private var result : (Int, MovieType)?
    private var page = 1
    
    private var topRatedItem: UIAction!
    private var popularItem: UIAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homePresenter = HomePresenter(homeView: self)
        
        //By default, Top Rated movies are fetched.
        UserDefaults.standard.set(MovieType.topRated.rawValue, forKey: "UserPreference")
        result = getMovieCountAndType(preference: "TopRated")
        
        setupViews()
        setupCollectionView()
        checkConnectivity()
    }
    
    private func setupViews() {
        title = "Top Rated Movies"
        if #available(iOS 14.0, *) {
            
            topRatedItem = UIAction(title: "Top Rated Movies", image: UIImage(systemName: "chart.line.uptrend.xyaxis.circle"), handler: { [weak self] _ in
                guard let self = self else { return }
                UserDefaults.standard.set(MovieType.topRated.rawValue, forKey: "UserPreference")
                self.homePresenter?.fetchTopRatedMovies(page: self.page)
                self.result = self.getMovieCountAndType(preference: MovieType.topRated.rawValue)
                self.title = "Top Rated Movies"
                self.toggleTopRatedItem(state: .on)
                self.togglePopularItem(state: .off)
            })
            
            popularItem = UIAction(title: "Popular Movies", image: UIImage(systemName: "flame"), handler: { [weak self] _ in
                guard let self = self else { return }
                UserDefaults.standard.set(MovieType.popular.rawValue, forKey: "UserPreference")
                self.homePresenter?.fetchPopularMovies(page: self.page)
                self.result = self.getMovieCountAndType(preference: MovieType.popular.rawValue)
                self.title = "Popular Movies"
                self.toggleTopRatedItem(state: .off)
                self.togglePopularItem(state: .on)
            })
            
            self.topRatedItem.state = .on
            self.popularItem.state = .off
            
            
            let menuItems: [UIAction] = [topRatedItem, popularItem]
            
            let menu =
            UIMenu(title: "Show movies menu", image: nil, identifier: nil, options: [], children: menuItems)
            let sortButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "list.bullet"), primaryAction: nil, menu: menu)
            
            navigationItem.rightBarButtonItem = sortButton
            navigationItem.rightBarButtonItem?.tintColor = UIColor(rgb: Constants.Colors.primaryYellowColor)
        }
        
        else {
            // Fallback on earlier versions
        }
        
    }
    
    
    
    func toggleTopRatedItem(state: UIMenuElement.State) {
        if topRatedItem.state == .on {
            topRatedItem.state = .off
        } else {
            topRatedItem.state = .on
        }
    }
    
    func togglePopularItem(state: UIMenuElement.State) {
        if popularItem.state == .on {
            popularItem.state = .off
        } else {
            popularItem.state = .on
        }
    }
    
    private func checkConnectivity() {
        if Reachability.isConnectedToNetwork() {
            //Get data from Internet
            homePresenter?.fetchPopularMovies(page: page)
            homePresenter?.fetchTopRatedMovies(page: page)
//            homePresenter?.fetchFavoriteMovies()
        } else {
            //Switch to Favorites Tab
            let alert = UIAlertController(title: "You're disconnected to Internet.", message: "Your phone is not connected to internet. You have been switched to Favorites movies.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true)
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Constants.XIBs.MovieCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.CollectionViewCells.MovieCell)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 170, height: 285)
        flowLayout.minimumLineSpacing = 8.0
        flowLayout.minimumInteritemSpacing = 8.0
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.showsHorizontalScrollIndicator = false
    }
    
    func reloadData() {
        DispatchQueue.main.async {[weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func getMovieCountAndType(preference: String) -> (Int, MovieType) {
        guard let topRatedMoviesCount = homePresenter?.topRatedMoviesList?.results?.count, let popularMoviesCount = homePresenter?.popularMoviesList?.results?.count else { return (0, MovieType.topRated) }
        
        switch MovieType(rawValue: preference) {
        case .topRated:
            if MovieType.topRated.rawValue == preference {
                return (topRatedMoviesCount, MovieType.topRated)
            }
        case .popular:
            if MovieType.popular.rawValue == preference {
                return (popularMoviesCount, MovieType.popular)
            }
            //
            //        case .favorites:
            //            if MovieType.favorites.rawValue == preference {
            //                return (favoriteMoviesCount, MovieType.favorites)
            //            }
        case .none:
            return (0, MovieType.topRated)
        }
        
        return (0, MovieType.topRated)
    }
    
    
}

//MARK: Extensions

//MARK: CollectionView
@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let userPreference = UserDefaults.standard.value(forKey: "UserPreference") else { return 0 }
        result = getMovieCountAndType(preference: userPreference as! String)
        return result?.0 ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCells.MovieCell, for: indexPath) as? MovieCollectionViewCell else { return UICollectionViewCell() }
        
        guard let userPreference = UserDefaults.standard.value(forKey: "UserPreference") else { return UICollectionViewCell() }
        result = getMovieCountAndType(preference: userPreference as! String)
        
        switch result?.1 ?? MovieType.topRated {
        case .topRated:
            cell.configure(name: homePresenter?.topRatedMoviesList?.results?[indexPath.row].title ?? "", movieImageURL: homePresenter?.topRatedMoviesList?.results?[indexPath.row].poster_path ?? "")
            
        case .popular:
            cell.configure(name: homePresenter?.popularMoviesList?.results?[indexPath.row].title ?? "", movieImageURL: homePresenter?.popularMoviesList?.results?[indexPath.row].poster_path ?? "")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch result?.1 ?? MovieType.topRated {
        case .topRated:
            homePresenter?.userMoviePreference = .topRated
            homePresenter?.navigateToMovie(at: indexPath.row)
        case .popular:
            homePresenter?.userMoviePreference = .popular
            homePresenter?.navigateToMovie(at: indexPath.row)
        }
    }
    
    //MARK: Pagination
    //UICollectionView extends UIScrollView, so we can access its functions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        if position > (self.collectionView.contentSize.height-30-scrollView.frame.size.height) {
            switch result?.1 ?? MovieType.topRated {
            case .topRated:
                self.page += 1
                print(page)
                self.homePresenter?.fetchTopRatedMovies(page: self.page)
            case .popular:
                self.page += 1
                self.homePresenter?.fetchPopularMovies(page: self.page)
            }
        }
    }
}
