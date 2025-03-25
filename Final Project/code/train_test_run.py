### Import Statements ###
import timm, os, torch, csv
import torchvision.transforms as transforms
from torchvision.datasets import ImageFolder
from torch.utils.data import DataLoader
from tqdm import tqdm
from torchsummary import summary
from sklearn.metrics import confusion_matrix
from datetime import datetime
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns

def complete_run(model_name="hf_hub:timm/deit3_large_patch16_224.fb_in22k_ft_in1k", learning_rate=1e-3):
    ### Hyperparameters ###
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    TRAINING_IMAGE_DIRECTORY = "CNFOOD-241/train600x600_small"
    TESTING_IMAGE_DIRECTORY = "CNFOOD-241/val600x600_small"
    PLOT_FOLDER = "result_plots"
    LOG_PATH = "run_logs.csv"
    BATCH_SIZE = 100
    NUM_EPOCHS = 100
    MODEL_NAME = model_name
    patience = 5
    start_from = 5
    LEARNING_RATE = learning_rate
    HEADER_ROW = ["RUN DATE", "MODEL", "EPOCH COUNT", "LEARNING RATE", "TOP-1 ACCURACY", "TOP-3 ACCURACY", "TOP-5 ACCURACY"]

    if not os.path.exists(PLOT_FOLDER):os.makedirs(PLOT_FOLDER)

    if not os.path.exists(LOG_PATH):
        with open(LOG_PATH, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(HEADER_ROW)

    ### Loading the Model ###
    model = timm.create_model(MODEL_NAME, pretrained=True)
    input_size = model.default_cfg['input_size']
    mean = model.default_cfg['mean']
    std = model.default_cfg['std']

    ### Setting up the data ###
    image_transformation = transforms.Compose([
        transforms.Resize((input_size[1], input_size[2])),
        transforms.ToTensor(),
        transforms.Normalize(mean=mean, std=std), ])

    train_dataset = ImageFolder(TRAINING_IMAGE_DIRECTORY, image_transformation)
    test_dataset = ImageFolder(TESTING_IMAGE_DIRECTORY, image_transformation)

    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=BATCH_SIZE)

    ### Setting up the model for training ###

    for param in model.parameters():
        param.requires_grad = False

    model.reset_classifier(num_classes=len(train_dataset.classes))

    for param in model.get_classifier().parameters(): param.requires_grad = True

    model.to(device)

    optimizer = torch.optim.AdamW(model.get_classifier().parameters(), lr=LEARNING_RATE)
    criterion = torch.nn.CrossEntropyLoss()

    model.train()

    # summary(model, (input_size[0], input_size[1], input_size[2]))  # Uncomment this line to see the model summary

    ### Fine-Tuning the Model ###
    best_val_accuracy = 0.0
    no_improvement_count = 0

    for epoch in range(NUM_EPOCHS):
        model.train()  # Switching the model to training
        training_loss, correct_top1, correct_top3, correct_top5, correct_top10, total_predictions = 0, 0, 0, 0, 0, 0

        # Training loop
        for inputs, labels in tqdm(train_loader, desc=f"Epoch {epoch + 1}/{NUM_EPOCHS} [Training]", ncols=100):
            inputs = inputs.to(device)
            labels = labels.to(device)

            optimizer.zero_grad()

            outputs = model(inputs)
            loss = criterion(outputs, labels)

            loss.backward()
            optimizer.step()

            training_loss += loss.item() * inputs.size(0)
            total_predictions += labels.size(0)

            _, predicted = outputs.topk(10, dim=1, largest=True, sorted=True)  # Get top 10 predictions

            # Compare the correct labels with the top-10 predictions
            labels_expanded = labels.view(-1, 1).expand_as(predicted)
            correct = predicted.eq(labels_expanded)

            # Checking for predictions in top-1, top-3, top-5, top-10
            correct_top1 += correct[:, :1].sum().item()
            correct_top3 += correct[:, :3].sum().item()
            correct_top5 += correct[:, :5].sum().item()
            correct_top10 += correct[:, :10].sum().item()

        # Calculating the loss and accuracy metrics for the current epoch
        epoch_loss = training_loss / len(train_dataset)
        top1_acc = correct_top1 / total_predictions
        top3_acc = correct_top3 / total_predictions
        top5_acc = correct_top5 / total_predictions
        top10_acc = correct_top10 / total_predictions

        print(
            f"Epoch {epoch + 1}/{NUM_EPOCHS} Training - Loss: {epoch_loss:.4f}, Top-1 Acc: {top1_acc:.4f}, Top-3 Acc: {top3_acc:.4f}, Top-5 Acc: {top5_acc:.4f}, Top-10 Acc: {top10_acc:.4f}")

        val_epoch_loss, val_correct_top1, val_correct_top3, val_correct_top5, val_correct_top10, val_total_predictions = 0, 0, 0, 0, 0, 0
        model.eval()  # Switching the model to the evaluation mode

        with torch.no_grad():
            ### Validation Loop ###
            for inputs, labels in tqdm(test_loader, desc=f"Epoch {epoch + 1}/{NUM_EPOCHS} [Validation]", ncols=100):
                inputs = inputs.to(device)
                labels = labels.to(device)

                outputs = model(inputs)
                loss = criterion(outputs, labels)

                val_epoch_loss += loss.item() * inputs.size(0)
                val_total_predictions += labels.size(0)

                _, predicted = outputs.topk(10, dim=1, largest=True, sorted=True)  # Get top 10 predictions

                # Compare the correct labels with the top-10 predictions
                labels_expanded = labels.view(-1, 1).expand_as(predicted)
                correct = predicted.eq(labels_expanded)

                # Checking for predictions in top-1, top-3, top-5, top-10
                val_correct_top1 += correct[:, :1].sum().item()
                val_correct_top3 += correct[:, :3].sum().item()
                val_correct_top5 += correct[:, :5].sum().item()
                val_correct_top10 += correct[:, :10].sum().item()

        # Calculating the loss and accuracy metrics for the current epoch
        val_epoch_loss = val_epoch_loss / len(test_dataset)
        val_top1_acc = val_correct_top1 / val_total_predictions
        val_top3_acc = val_correct_top3 / val_total_predictions
        val_top5_acc = val_correct_top5 / val_total_predictions
        val_top10_acc = val_correct_top10 / val_total_predictions

        print(f"Epoch {epoch + 1}/{NUM_EPOCHS} Validation - Loss: {val_epoch_loss:.4f}, Top-1 Acc: {val_top1_acc:.4f}, Top-3 Acc: {val_top3_acc:.4f}, Top-5 Acc: {val_top5_acc:.4f}, Top-10 Acc: {val_top10_acc:.4f}\n")

        # Early Stopping Check based on Validation Top-1 Accuracy
        if epoch > start_from:
            if val_top1_acc > best_val_accuracy - 0.001:
                best_val_accuracy = val_top1_acc
                no_improvement_count = 0
            else:
                no_improvement_count += 1

            if no_improvement_count >= patience:
                print(f"Early stopping triggered. No improvement in validation accuracy for {patience} epochs.")
                break

    ### Plotting the Confusion Matrix ###
    model.eval()  # Switching the model to the eval. mode
    all_preds = []
    all_labels = []

    with torch.no_grad():
        for inputs, labels in tqdm(test_loader, desc="Test-Run for the Confusion Matrix", ncols=100):
            inputs = inputs.to(device)
            labels = labels.to(device)

            outputs = model(inputs)
            _, preds = torch.max(outputs, 1)

            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())

    # Creating a dictionary of true labels and the labels in the PyTorch data
    idx_to_class = {v: k for k, v in train_dataset.class_to_idx.items()}
    class_names = [idx_to_class[i] for i in range(len(idx_to_class))]

    # Creating and normalizing the confusion matrix
    cm = confusion_matrix(all_labels, all_preds)
    cm_normalized = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]

    ### Plotting the confusion matrix ###
    plt.figure(figsize=(35, 30))
    ax = sns.heatmap(cm_normalized, vmin=0, vmax=1)

    plt.title('Confusion Matrix for CNFOOD-241', fontsize=32, fontweight='bold')
    plt.ylabel('True Label', fontsize=30, fontweight='bold')
    plt.xlabel('Predicted Label', fontsize=30, fontweight='bold')

    ax.set_xticklabels(class_names, rotation=75, fontsize=16)
    ax.set_yticklabels(class_names, rotation=15, fontsize=16)

    cbar = ax.collections[0].colorbar
    cbar.ax.tick_params(labelsize=32)

    ax.set(xlim=(0, len(class_names)), ylim=(len(class_names), 0))

    timestamp = datetime.now().strftime("%y%m%d%H%M%S")
    file_name = f"{timestamp}_confusion_matrix.png"
    plt.savefig("result_plots/" + file_name, dpi=300)

    ### Logging the Data ###
    final_results = [
        timestamp,
        MODEL_NAME,
        epoch + 1,
        LEARNING_RATE,
        val_top1_acc,
        val_top3_acc,
        val_top5_acc,
    ]

    # Write to the CSV file
    with open(LOG_PATH, mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(final_results)
    
