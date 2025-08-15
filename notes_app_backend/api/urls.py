from django.urls import path
from .views import RegisterView, NotesListCreateView
from rest_framework_simplejwt.views import TokenObtainPairView

urlpatterns = [
    path('register/', RegisterView.as_view()),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('notes/', NotesListCreateView.as_view()),
]
